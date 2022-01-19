import Foundation

struct UserDataKeychain: Keychain {
  // Make sure the account name doesn't match the bundle identifier!
  var account = "com.enebin.SidePlace.Details"
  var service = "userIdentifier"

  typealias DataType = UserData
}
