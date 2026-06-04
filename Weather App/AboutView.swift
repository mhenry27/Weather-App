//
//  AboutView.swift
//  Weather App
//
//  Created by Mackinley Henry on 6/3/26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("About")
                    .font(.largeTitle)
                    .bold()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Mackinley Henry")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Computer Science student at the University of Rochester with a passion for building user-friendly applications and exploring innovative technology solutions.")
                        .font(.subheadline)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("About PM Accelerator")
                        .font(.headline)

                    Text("""
                    PM Accelerator is a professional development organization that helps aspiring and experienced Product Managers build the skills needed to succeed in the industry. Through mentorship, hands-on projects, interview preparation, leadership training, and networking opportunities, the program supports members at every stage of their product management journey.

                    The organization also offers specialized programs focused on AI Product Management, career growth, resume development, and leadership advancement.
                    """)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Weather App")
                        .font(.headline)

                    Text("""
                    This weather application was developed as part of the PM Accelerator program. It provides real-time weather information, forecasts, travel planning tools, packing recommendations, currency conversion, and other features designed to help users prepare for their trips.
                    """)
                }
            }
            .padding()
        }
        .background(Color.blue.opacity(0.12))
    }
}

#Preview {
    AboutView()
        .environmentObject(AppSettings())
}
