#! /usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import readline
from random import randint
from six.moves import input
import sys

COLORS = ('R', 'G', 'B', 'W', 'Y')


def random_color(colors=COLORS):
    return colors[randint(0, len(colors)-1)]


def generate_puzzle(num_pegs, ensure_unique_colors=False):
    puzzle = [random_color() for x in range(0, num_pegs)]
    if ensure_unique_colors:
        if len(puzzle) == len(set(puzzle)):
            return puzzle
        else:
            return generate_puzzle(num_pegs, ensure_unique_colors=True)
    return puzzle


def eval_guess(guess, solution):
    feedback = []
    for idx, piece in enumerate(guess):
        if piece == solution[idx]:
            feedback.append('B')
        elif piece in solution:
            feedback.append('W')
    return feedback


def provide_feedback(guess, solution, guess_num=0):
    evaluation = eval_guess(guess, solution)
    print('Guess #{}:'.format(guess_num))
    print('Correct Color + Placement: {}'.format(evaluation.count('B')))
    print('Correct Color: {}'.format(evaluation.count('W')))


def capture_guess(prompt='master the mind! => '):
    return list(input(prompt).lstrip().rstrip())


def main(settings):
    num_guesses = 1
    solution = generate_puzzle(settings.num_pegs, (not settings.possible_color_repetition))
    guess = capture_guess()
    provide_feedback(guess, solution, num_guesses)

    while guess != solution and (num_guesses < settings.max_guesses):
        guess = capture_guess()
        num_guesses = num_guesses + 1
        provide_feedback(guess, solution, num_guesses)

    if guess == solution:
        print('Solved in {} guesses!'.format(num_guesses))

    if num_guesses == settings.max_guesses:
        print('You ran out of guesses!')
        print('The solution was: {}'.format(''.join(solution)))

    sys.exit(0)


def display_settings(settings):
    print('Possible Colors: {}'.format(','.join(COLORS)))

    def prettify_setting(setting_name):
        return setting_name.title().replace('_', ' ')

    for setting_name in settings.__dict__.keys():
        print('{}: {}'.format(prettify_setting(setting_name), settings.__dict__.get(setting_name)))


def settings_are_sane(settings):
    if (not settings.possible_color_repetition) and (settings.num_pegs > len(COLORS)):
        msg = """The number of pegs can't be higher than the number"""
        msg = msg + """ of possible colors unless you also set --possible_color_repetition."""
        print(msg)
        return False
    return True


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="master.the.mind")
    parser.add_argument('--possible_color_repetition', required=False, action="store_true", default=False)
    parser.add_argument('--max_guesses', required=False, type=int, default=12)
    parser.add_argument('--num_pegs', required=False, type=int, default=4)
    settings = parser.parse_args()

    display_settings(settings)
    if settings_are_sane(settings):
        main(settings)
