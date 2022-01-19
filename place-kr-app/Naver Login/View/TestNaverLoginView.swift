import SwiftUI
import WebKit

struct TestNaverLoginView: View {
    var body: some View {
        NaverVCRepresentable { userData in
            print("결과 \(userData)")
        }
    }
}

struct TestNaverLoginView_Previews: PreviewProvider {
    static var previews: some View {
        TestNaverLoginView()
    }
}
