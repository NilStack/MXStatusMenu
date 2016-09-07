extension Int32 {
    
    /// Checks if a specified bit is set in this bitmask
	func bitIsSet(_ bit: Int32) -> Bool {
		return self & bit == bit
	}
}
