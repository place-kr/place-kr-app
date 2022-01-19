import SwiftUI

struct TestNaverLoginView: View {
    var body: some View {
        NaverVCRepresentable { email in
            let snsAccount = email
            print("결과 \(email)")
        }
    }
}

struct TestNaverLoginView_Previews: PreviewProvider {
    static var previews: some View {
        TestNaverLoginView()
    }
}
