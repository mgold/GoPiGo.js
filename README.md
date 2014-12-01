# gopigo.js

Program your [GoPiGo](https://github.com/DexterInd/GoPiGo) in JavaScript.

## About

The GoPiGo is a robotics platform made by Dexter Industries. It uses I2C to
communicate between the Pi and a custom board (heavily inspired by the
Arduino), rather than use the Pi's GPIO pins. For this reason, traditional
NodeBots tools like
[Johnny-Five](https://github.com/rwaldron/johnny-five)/[Raspi-IO](https://github.com/bryan-m-hughes/raspi-io/)
are not helpful.

Thankfully, DI has made their [Python
library](https://github.com/DexterInd/GoPiGo/blob/master/Software/Python/gopigo.py)
open source and freely licensed. This package is a fairly straightforward
translation of that Python library into CoffeeScript. (The syntactic similarity
is striking.) For convenience, the compiled JavaScript file is also included.

The API is virtually identical, with a few minor changes noted in the source
code. Note that this means the library is synchronous, which is okay
considering the underlying I2C driver is synchronous too. If you have questions
about a particular function, consult DI's
[docs](http://www.dexterindustries.com/GoPiGo/learning/python-programming-for-the-raspberry-pi-gopigo/)
or the CoffeeScript source.

The package is licensed the same as DI's: CC BY-SA 3.0.

## Install

If you don't already have Node installed on your Pi, [these
instructions](http://weworkweplay.com/play/raspberry-pi-nodejs/) seem as good
as any. Then:

````
npm install gopigo
````

It may take some time to build the dependencies. Read the next section while
you're waiting.

## Troubleshooting

If you get "TypeError: Failed to set address", add the following to
`/etc/rc.local/` above the `exit` command, and then execute it with `sudo`:

````
chmod o+rw /dev/i2c*
````

You should only attempt to `npm install gopigo` on the Pi itself. This will
install [node-i2c](https://github.com/kelly/node-i2c). Most of the steps listed
in its README have already been done to your GoPiGo-ready Pi, and the one that
hasn't I just mentioned above. If you have further issues with i2c, consult the
node-i2c README.

Sometimes issuing multiple commands over the bus (particularly LEDs) causes
intermittent failures. I've had success using `setTimeout(func, 0)` in these
cases.

If you encounter any other problems, please open an issue or send a pull
request!
