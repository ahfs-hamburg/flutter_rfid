/// Converts a list of bytes into a hexadecimal string representation.
///
/// This function takes a list of integers, where each integer represents a byte,
/// and converts each byte into its hexadecimal string equivalent. The resulting
/// hexadecimal strings are concatenated into a single string, separated by spaces.
/// Each hexadecimal value is padded to ensure it has at least two digits and is
/// converted to uppercase.
///
/// ## Parameters
///   - `bytes`: A list of integers representing the bytes to be converted to hexadecimal.
///
/// ## Returns
///   A `String` representing the hexadecimal values of the input bytes, separated by spaces.
///
/// ## Example
/// ```dart
/// final hexString = convertBytesToHex([0x12, 0xAB, 0xFF]);
/// print(hexString); // Prints "12 AB FF"
/// ```
///
/// ## Note
///   - The input list should contain integers in the range 0x00 to 0xFF. Values outside
///     this range may not be converted accurately.
String convertBytesToHex(List<int> bytes) {
  return bytes
      .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
      .join(' ');
}

/// Rotates the elements of a list by a specified number of positions.
///
/// This function shifts the elements of the provided list to the right by [v] positions,
/// wrapping around to the beginning of the list. If [v] is greater than the length of the list,
/// it wraps [v] around using the modulus of the list's length. The function returns a new list
/// with the rotated elements.
///
/// ## Parameters
///   - `list`: A list of integers that will be rotated.
///   - `v`: The number of positions to rotate the list by. Can be positive for right rotation
///          or negative for left rotation.
///
/// ## Returns
///   A new list containing the rotated elements of the original list. If the original list is
///   empty or [v] is 0, the original list is returned unchanged.
///
/// ## Example
/// ```dart
/// final myList = [1, 2, 3, 4, 5];
/// final rotatedList = rotateListData(myList, 2); // Returns [4, 5, 1, 2, 3]
/// final rotatedListLeft = rotateListData(myList, -2); // Returns [3, 4, 5, 1, 2] for left rotation
/// ```
///
/// ## Note
///   - If [list] is empty, the function immediately returns the original empty list.
///   - The function creates a shallow copy of the list for the return value. Modifications
///     to the elements of the returned list do not affect the original list.
List<int> rotateListData(List<int> list, int v) {
  if (list.isEmpty) return list;
  var i = v % list.length;
  return list.sublist(i)..addAll(list.sublist(0, i));
}
