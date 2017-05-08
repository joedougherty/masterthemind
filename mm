#! /usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import readline
from random import randint
from six.moves import input
import sys


def random_color(colors):
    return colors[randint(0, len(colors)-1)]


def generate_puzzle(num_pegs, possible_colors, ensure_unique_colors=False):
    puzzle = [random_color(possible_colors) for x in range(0, num_pegs)]
    if ensure_unique_colors:
        if len(puzzle) == len(set(puzzle)):
            return puzzle
        else:
            return generate_puzzle(num_pegs, possible_colors, ensure_unique_colors=True)
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


def capture_guess(prompt='\nmaster the mind! => '):
    try:
        return list(input(prompt).lstrip().rstrip())
    except KeyboardInterrupt:
        print('Goodbye!')
        sys.exit(0)


def main(settings):
    num_guesses = 1
    solution = generate_puzzle(settings.num_pegs, settings.possible_colors, (not settings.possible_color_repetition))
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
    def prettify_setting(setting_name):
        return setting_name.title().replace('_', ' ')

    for setting_name in settings.__dict__.keys():
        print('{}: {}'.format(prettify_setting(setting_name), settings.__dict__.get(setting_name)))


def settings_are_sane(settings):
    if (not settings.possible_color_repetition) and (settings.num_pegs > settings.possible_colors):
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
    colors_help = "A string composed of individual letters, each representing a color. Example: RBGYV"
    parser.add_argument('--possible_colors', required=False, type=str, default='RGBWY', help=colors_help)
    settings = parser.parse_args()
    settings.possible_colors = list(set(settings.possible_colors))

    display_settings(settings)
    if settings_are_sane(settings):
        main(settings)
