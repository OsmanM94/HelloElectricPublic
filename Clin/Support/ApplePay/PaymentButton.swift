//
//  ApplePaymentView.swift
//  Clin
//
//  Created by asia on 01/09/2024.
//
//
//import SwiftUI
//import UIKit
//import PassKit
//
//struct PaymentButton: View {
//    let paymentHandler = PaymentHandler()
//
//    var body: some View {
//        Button(action: {
//            self.paymentHandler.startPayment { success in
//                if success {
//                    print("Success")
//                } else {
//                    print("Failed")
//                }
//            }
//        }, label: { EmptyView() } )
//            .buttonStyle(PaymentButtonStyle())
//    }
//}
//
//#Preview {
//    PaymentButton()
//}
//
//struct PaymentButtonStyle: ButtonStyle {
//    func makeBody(configuration: Self.Configuration) -> some View {
//        return PaymentButtonHelper()
//    }
//}
//    
//struct PaymentButtonHelper: View {
//    var body: some View {
//        PaymentButtonRepresentable()
//            .frame(width: 200, height: 50)
//    }
//}
//
//extension PaymentButtonHelper {
//    struct PaymentButtonRepresentable: UIViewRepresentable {
//        
//        var button: PKPaymentButton {
//            let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .automatic) /*customize here*/
//            button.cornerRadius = 4.0 /* also customize here */
//            return button
//        }
//        
//        func makeUIView(context: Context) -> PKPaymentButton {
//            return button
//        }
//        func updateUIView(_ uiView: PKPaymentButton, context: Context) { }
//    }
//}

import SwiftUI
import UIKit
import PassKit

struct PaymentButton: View {
    let paymentHandler = PaymentHandler()
    let action: (Bool) -> Void
    
    init(action: @escaping (Bool) -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: {
            self.paymentHandler.startPayment { success in
                DispatchQueue.main.async {
                    self.action(success)
                }
            }
        }, label: { EmptyView() })
        .buttonStyle(PaymentButtonStyle())
    }
}

struct PaymentButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return PaymentButtonHelper()
    }
}
    
struct PaymentButtonHelper: View {
    var body: some View {
        PaymentButtonRepresentable()
            .frame(width: 100, height: 50)
    }
}

extension PaymentButtonHelper {
    struct PaymentButtonRepresentable: UIViewRepresentable {
        var button: PKPaymentButton {
            let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .automatic)
            button.cornerRadius = 4.0
            return button
        }
        
        func makeUIView(context: Context) -> PKPaymentButton {
            return button
        }
        func updateUIView(_ uiView: PKPaymentButton, context: Context) { }
    }
}

#Preview {
    PaymentButton { success in
        print(success ? "Payment Successful" : "Payment Failed")
    }
}
