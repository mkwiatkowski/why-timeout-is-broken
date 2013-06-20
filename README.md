# Why `Timeout` module is broken

Find out by yourself by running the scripts. You need local MongoDB running on standard port 27017. You may need to change the timeout values for some of the examples to work on your machine.

    $ bundle install

    $ ruby 1_connect_and_insert.rb
    ................................................................................
    ................................................................................
    ................................................................................
    ................................................................................
    ............................................................................^C

Mongo takes its time, no connection errors happen for the most part.

    $ ruby 2_connect_and_insert_with_timeout.rb
    ....................TTTTT....T...........................................T......
    ................................TT.T...T....................................TTTT
    .........TT.....................................................................
    ....T..................T....................................T...........TTTTT...
    ............................................................................^C

Placing a time limit will cause timeouts for some requests, as expected.

    $ ruby 3_connect_once_then_insert_with_timeout.rb
    ..........................................T.....................................
    .............................TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
    TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
    TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
    TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT^C

Unfortunately, timeout implementation may cause a deadlock, if the timed out block still holds the lock to a resource (in this case some internal lock of the mongo driver). Killing threads isn't such a good idea after all.

    $ ruby 4_connect_with_pool_once_then_insert_with_timeout.rb
    ................................................................................
    ................................................................................
    ................................................................................
    .........................................................TTTTTTTTTTTTTTTTTTTTTTT
    TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT^C

Maintaining a connections pool doesn't solve anything either.

    $ ruby 5_connect_with_op_timeout_then_insert.rb
    ................................................................................
    ................................................................................
    ........................T.......................................................
    ................................................................................
    .................................................T..........................^C

Using [Mongo's op_timeout option](https://github.com/mongodb/mongo-ruby-driver#socket-timeouts) does the trick as it uses `IO.select` instead of `Timeout`.

If you use `Timeout` in a web application, you may experience connections hang in `SYN_RECV` state. Stracing the Ruby process will reveal it is hanging on a call to [futex](http://man7.org/linux/man-pages/man2/futex.2.html).


# Affected versions

I tested this under the following Ruby versions:

- ruby 2.0.0p195 (2013-05-14 revision 40734) [i686-linux]
- ruby 1.9.3p392 (2013-02-22 revision 39386) [i686-linux]
- ruby 1.9.2p320 (2012-04-20 revision 35421) [i686-linux]
- ruby 1.8.7 (2012-10-12 patchlevel 371) [i686-linux]
- jruby 1.7.3 (1.9.3p385) 2013-02-21 dac429b on OpenJDK Server VM 1.7.0_21-b02 [linux-i386]


# Further reading

- [Ruby's Thread#raise, Thread#kill, timeout.rb, and net/protocol.rb libraries are broken](http://blog.headius.com/2008/02/ruby-threadraise-threadkill-timeoutrb.html)
- [timeout.rb implementation](https://github.com/ruby/ruby/blob/trunk/lib/timeout.rb)
- [Timeout.java implementation](https://github.com/jruby/jruby/blob/master/src/org/jruby/ext/timeout/Timeout.java)
