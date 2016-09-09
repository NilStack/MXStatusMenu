import Foundation

class Timer {
	
	/// Closure will be called every time the timer fires
	typealias Closure = (_ timer: Timer) -> ()
	
    /// Parameters
	let closure: Closure
	let queue: DispatchQueue
	var isSuspended: Bool = true
    
    /// The default initializer
	init(queue: DispatchQueue, closure: @escaping Closure) {
		self.queue = queue
		self.closure = closure
	}
    
    /// Suspend the timer before it gets destroyed
	deinit {
		suspend()
	}
    
    /// This timer implementation uses Grand Central Dispatch sources
	lazy var source: DispatchSource = {
		DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: self.queue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as! DispatchSource
		}()
    
    /// Convenience class method that creates and start a timer
	class func repeatEvery(_ repeatEvery: Double, closure: @escaping Closure) -> Timer {
		let timer = Timer(queue: DispatchQueue.global(), closure: closure)
		timer.resume(0, repeat: repeatEvery, leeway: 0)
		return timer
	}
    
    /// Fire the timer by calling its closure
	func fire() {
		closure(self)
	}
    
    /// Start or resume the timer with the specified double values
	func resume(_ start: Double, repeat: Double, leeway: Double) {
		let NanosecondsPerSecond = Double(NSEC_PER_SEC)
		resume(Int64(start * NanosecondsPerSecond), repeat: UInt64(`repeat` * NanosecondsPerSecond), leeway: UInt64(leeway * NanosecondsPerSecond))
	}
    
    /// Start or resume the timer with the specified integer values
	func resume(_ start: Int64, repeat: UInt64, leeway: UInt64) {
		if isSuspended {
			let startTime = DispatchTime.now() + Double(start) / Double(NSEC_PER_SEC)
            
            source.scheduleRepeating(
                deadline: startTime,
                interval: DispatchTimeInterval.seconds(Int(`repeat`)),
                leeway: DispatchTimeInterval.seconds(Int(leeway))
            )
            
            /*
             source.  { [weak self] in
             if let timer = self {
             timer.fire()
             }
             }
             
             public func scheduleOneshot(deadline: DispatchTime, leeway: DispatchTimeInterval = default)
             
             public func scheduleOneshot(wallDeadline: DispatchWallTime, leeway: DispatchTimeInterval = default)
             
             public func scheduleRepeating(deadline: DispatchTime, interval: DispatchTimeInterval, leeway: DispatchTimeInterval = default)
             
             public func scheduleRepeating(deadline: DispatchTime, interval: Double, leeway: DispatchTimeInterval = default)
             
             public func scheduleRepeating(wallDeadline: DispatchWallTime, interval: DispatchTimeInterval, leeway: DispatchTimeInterval = default)
             
             public func scheduleRepeating(wallDeadline: DispatchWallTime, interval: Double, leeway: DispatchTimeInterval = default)
             
             source.resume()
             isSuspended = false
             }
             */
        }
    }
    
    /// Suspend the timer
	func suspend() {
		if !isSuspended {
			source.suspend()
			isSuspended = true
		}
	}
}
