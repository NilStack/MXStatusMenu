import Cocoa
import Darwin

class CPU {
	
	/// The ticks of the latest check
	var latestTicks = [integer_t]()
    
    /// The number of cpu threads
    var numberOfThreads: Int {
    return latestTicks.count
    }
	
	/// Initialize the latestTicks so that we know the number of cpu threads
	init() {
		latestTicks = ticks()
	}
	
	/// Returns the current cpu load as an array of percentages for each cpu thread
	func load() -> [Double] {
		let ticks = self.ticks()
		var load = [Double](repeating: 0, count: ticks.count)
		if ticks.count == latestTicks.count {
			for (i, loadInfo) in ticks.enumerated() {
//				let delta = loadInfo.delta(latestTicks[i])
//				let total = delta.cpu_ticks.0 + delta.cpu_ticks.1 + delta.cpu_ticks.2
//				if total > 0 {
//					load[i] = Double(delta.cpu_ticks.0 + delta.cpu_ticks.1) / Double(total)
//				}
			}
		}
		latestTicks = ticks
		return load.sorted(by: {$0 > $1})
	}
	
	/// Returns the current ticks of each cpu thread
	func ticks() -> [integer_t] {
        
		var ticks = [integer_t]()
		let processorCount = UnsafeMutablePointer<natural_t>.allocate(capacity: 1)
		let loadInfos = UnsafeMutablePointer<processor_info_array_t?>.allocate(capacity: 1)
		let infoCount = UnsafeMutablePointer<mach_msg_type_number_t>.allocate(capacity: 1)
		
		// get the ticks
        if KERN_SUCCESS == host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, processorCount, loadInfos, infoCount),
            let loadInfo = loadInfos[0] {
            
			for i in 0..<Int(processorCount[0]) {
                ticks.append(loadInfo[i])
			}
		} else {
			ticks = latestTicks
		}
		
		// clean up
		processorCount.deallocate(capacity: 1)
		loadInfos.deallocate(capacity: 1)
		infoCount.deallocate(capacity: 1)
		return ticks
	}
}

/// note: processor_cpu_load_info.cpu_ticks contains four load infos: (user, system, idle, nice)
extension processor_cpu_load_info {
	
	/// Returns the delta of two load values
	func delta(_ laterValue: processor_cpu_load_info) -> processor_cpu_load_info {
		let userDelta = cpu_ticks.0.deltaByRecognizingOverflow(laterValue.cpu_ticks.0)
		let systemDelta = cpu_ticks.1.deltaByRecognizingOverflow(laterValue.cpu_ticks.1)
		let idleDelta = cpu_ticks.2.deltaByRecognizingOverflow(laterValue.cpu_ticks.2)
		let niceDelta = cpu_ticks.3.deltaByRecognizingOverflow(laterValue.cpu_ticks.3)
		return processor_cpu_load_info(cpu_ticks: (userDelta, systemDelta, idleDelta, niceDelta))
	}
}
