ansi(x) = string("\x1b[", x, "m")
clear = ansi(0)
bold = ansi(1)
black = ansi(30)
red = ansi(31)
green = ansi(32)
yellow = ansi(33)
blue = ansi(34)
magenta = ansi(35)
cyan = ansi(36)
white = ansi(37)

"""
    log(str...)

    Simply prints the arguments provided. This may be reworked later to provide
    more robust logging capabilities (e.g. to files)
"""
log(str...) = println(str...)

"""
    warn(str...)

    Prints the arguments provided, but with a yellow color and a bold "WARNING"
    in front. This may be reworked later to provide more robust logging
    capabilities (e.g. to files)
"""
warn(str...) = println(bold, yellow, "WARNING: ", clear, yellow, str..., clear)

"""
    error(str...)

    Prints the arguments provided, but with a red color and a bold "ERROR" in
    front. This may be reworked later to provide more robust logging
    capabilities (e.g. to files)
"""
error(str...) = println(bold, red, "ERROR: ", clear, red, str..., clear)
