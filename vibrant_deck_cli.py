"""
vibrant_deck_cli - Adjust the screen saturation of the Steam Deck
Copyright (C) 2022 Agustín Mista <agustin@mista.me> (https://mista.me)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

import os
import sys
import struct
import subprocess

from argparse import ArgumentParser
from typing import List, Iterable

CTM_PROP = "GAMESCOPE_COLOR_MATRIX"

# ----------------------------------------
# Helpers

def saturation_to_coeffs(saturation: float) -> List[float]:
    coeff = (1.0 - saturation) / 3.0

    coeffs = [coeff] * 9
    coeffs[0] += saturation
    coeffs[4] += saturation
    coeffs[8] += saturation
    return coeffs

def float_to_long(x: float) -> int:
    return struct.unpack("!I", struct.pack("!f", x))[0]

def long_to_float(x: int) -> float:
    return struct.unpack("!f", struct.pack("!I", x))[0]

verbose = False
def message(msg: str):
    if verbose:
        print(msg)

# ----------------------------------------
# Low-level interaction with xprop

def set_xprop(prop_name: str, values: Iterable[int]):

    param = ",".join(map(str, values))

    command = ["xprop", "-root", "-f", prop_name,
               "32c", "-set", prop_name, param]

    if "DISPLAY" not in os.environ:
        command.insert(1, ":1")
        command.insert(1, "-display")

    completed = subprocess.run(command, stderr=sys.stderr, stdout=sys.stdout)

    return completed.returncode == 0

# ----------------------------------------
# Setter/getters for on-screen saturation

def set_saturation(saturation: float):
    # Generate color transformation matrix
    coeffs = saturation_to_coeffs(saturation)

    # represent floats as longs
    long_coeffs = map(float_to_long, coeffs)

    return set_xprop(CTM_PROP, long_coeffs)


def get_saturation() -> float:
    command = ["xprop", "-root", CTM_PROP]

    if "DISPLAY" not in os.environ:
        command.insert(1, ":1")
        command.insert(1, "-display")

    completed = subprocess.run(command, capture_output=True)
    stdout = completed.stdout.decode("utf-8")

    # Check the output
    # Good output: "GAMESCOPE_COLOR_MATRIX(CARDINAL) = 1065353216, 0, 0, 0, 1065353216, 0, 0, 0, 1065353216"
    # Bad output:  "GAMESCOPE_COLOR_MATRIX:  not found."
    if "=" not in stdout:
        sys.exit("error: could not retrieve current screen saturation\nxprop returned: %s" % stdout)

    # "1065353216, 0, 0, 0, 1065353216, 0, 0, 0, 1065353216"
    ctm_param = stdout.split("=")[1]
    # [1065353216, 0, 0, 0, 1065353216, 0, 0, 0, 1065353216]
    long_coeffs = list(map(int, ctm_param.split(",")))
    # [1.0, 0, 0, 0, 1.0, 0, 0, 0, 1.0]
    coeffs = list(map(long_to_float, long_coeffs))
    # 1.0
    saturation = round(coeffs[0] - coeffs[1], 2)

    return saturation

# ----------------------------------------
# Command-line options parser

parser = ArgumentParser(description="Set the screen saturation of the Steam Deck")
parser.add_argument("-q", "--quiet", action="store_false", dest="verbose", default=True, help="don't print messages to stdout")
parser.add_argument('saturation',    nargs="?",            type=float,     default=1.0,  help="desired screen saturation between 0.0 and 4.0 (default 1.0)")

# ----------------------------------------
# Entry point

if __name__ == "__main__":
    args = parser.parse_args()

    if args.verbose:
        verbose = True

    saturation = min(max(0.0, args.saturation), 4.0)

    message("setting screen saturation to %f" % saturation)
    set_saturation(saturation)
    new_saturation = get_saturation()
    message("screen saturation set to %f" % new_saturation)