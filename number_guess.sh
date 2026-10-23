#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read -r USERNAME

USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)" > /dev/null
  GAMES_PLAYED=0
  BEST_GAME=""
else
  IFS="|" read -r GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
GUESSES=0

while true
do
  read -r GUESS || [[ -n $GUESS ]] || exit
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  GUESSES=$((GUESSES + 1))
  GUESS_NUM=$((10#$GUESS))
  if (( GUESS_NUM == SECRET ))
  then
    break
  elif (( GUESS_NUM > SECRET ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]
then
  BEST_GAME=$GUESSES
fi
GAMES_PLAYED=$((GAMES_PLAYED + 1))

$PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'" > /dev/null

echo "You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!"
