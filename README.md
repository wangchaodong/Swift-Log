# Log

A description of this package.

A simple Log tool for swift.

## Usage
```
Log.log("hello world!")
Log.log("debug", marker: .debug)
Log.debug("debug")
Log.log("alloc", marker: .alloc)
Log.log("dealloc", marker: .dealloc)
Log.error("error")
Log.success("success")
Log.warning("warning")
Log.config.handler = { msg in
    // handle log message, such as cache log message, or show message alert

}

/** 
2022-07-16 02:39:01.283 FileIO.test():38 🟢 ✅ hello world!
2022-07-16 02:39:01.284 FileIO.test():39 🟢 🐛 debug
2022-07-16 02:39:01.285 FileIO.test():40 🟢 🐛 debug
2022-07-16 02:39:01.285 FileIO.test():41 🟢 ❇️ alloc
2022-07-16 02:39:01.286 FileIO.test():42 🟢 ♻️ dealloc
2022-07-16 02:39:01.286 FileIO.test():43 🟢 ❌ error
2022-07-16 02:39:01.287 FileIO.test():44 🟢 👍🏻 success
2022-07-16 02:39:01.287 FileIO.test():45 🟢 ⚠️ warning
*/
```
