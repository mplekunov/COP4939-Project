//
//  StatisticsView.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/26/23.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var dataReceiverViewModel: DataReceiverViewModel
    
    var body: some View {
        List {
            Section("Data Points Received") {
                Text("\(dataReceiverViewModel.session.data.count)")
            }.listRowBackground(Color.secondary)
            
            Section("Location Direction in Degrees") {
                LineChartView(
                    data: dataReceiverViewModel.session.data.map {
                        ChartData(
                            date: Date(timeIntervalSince1970: $0.timeStamp),
                            data: $0.location.directionInDegrees
                        )
                    }
                ).padding()
            }
            .listRowBackground(Color.secondary)
            
            Section("Location latitude") {
                
                LineChartView(
                    data: dataReceiverViewModel.session.data.map {
                        ChartData(
                            date: Date(timeIntervalSince1970: $0.timeStamp),
                            data: $0.location.coordinate.latitude
                        )
                    }
                ).padding()
            }
            .listRowBackground(Color.secondary)
            
            Section("Location longitude") {
                
                LineChartView(
                    data: dataReceiverViewModel.session.data.map {
                        ChartData(
                            date: Date(timeIntervalSince1970: $0.timeStamp),
                            data: $0.location.coordinate.longitude
                        )
                    }
                ).padding()
            }
            .listRowBackground(Color.secondary)
            
            Section("Attitude Pitch") {
                VStack {
                    LineChartView(
                        data: dataReceiverViewModel.session.data.map {
                            ChartData(
                                date: Date(timeIntervalSince1970: $0.timeStamp),
                                data: $0.motion.attitude.pitch
                            )
                        }
                    ).padding()
                }
            }.listRowBackground(Color.secondary)
            
            Section("Attitude Yaw") {
                VStack {
                    LineChartView(
                        data: dataReceiverViewModel.session.data.map {
                            ChartData(
                                date: Date(timeIntervalSince1970: $0.timeStamp),
                                data: $0.motion.attitude.yaw
                            )
                        }
                    ).padding()
                }
            }.listRowBackground(Color.secondary)
            
            Section("Attitude Roll") {
                VStack {
                    LineChartView(
                        data: dataReceiverViewModel.session.data.map {
                            ChartData(
                                date: Date(timeIntervalSince1970: $0.timeStamp),
                                data: $0.motion.attitude.roll
                            )
                        }
                    ).padding()
                }
            }
            .listRowBackground(Color.secondary)
            
            Section("G Force X") {
                VStack {
                    LineChartView(
                        data: dataReceiverViewModel.session.data.map {
                            ChartData(
                                date: Date(timeIntervalSince1970: $0.timeStamp),
                                data: $0.motion.gForce.x
                            )
                        }
                    ).padding()
                }
            }.listRowBackground(Color.secondary)
            
            Section("G Force Y") {
                VStack {
                    LineChartView(
                        data: dataReceiverViewModel.session.data.map {
                            ChartData(
                                date: Date(timeIntervalSince1970: $0.timeStamp),
                                data: $0.motion.gForce.y
                            )
                        }
                    ).padding()
                }
            }.listRowBackground(Color.secondary)
            
            Section("G Force z") {
                VStack {
                    LineChartView(
                        data: dataReceiverViewModel.session.data.map {
                            ChartData(
                                date: Date(timeIntervalSince1970: $0.timeStamp),
                                data: $0.motion.gForce.z
                            )
                        }
                    ).padding()
                }
            }
            .listRowBackground(Color.secondary)
            
            Section("Acceleration X") {
                VStack {
                    LineChartView(
                        data: dataReceiverViewModel.session.data.map {
                            ChartData(
                                date: Date(timeIntervalSince1970: $0.timeStamp),
                                data: $0.motion.acceleration.x
                            )
                        }
                    )
                    .padding()
                }
            }
            .listRowBackground(Color.secondary)
            
            Section("Acceleration Y") {
                VStack {
                    LineChartView(
                        data: dataReceiverViewModel.session.data.map {
                            ChartData(
                                date: Date(timeIntervalSince1970: $0.timeStamp),
                                data: $0.motion.acceleration.y
                            )
                        }
                    )
                    .padding()
                }
            }
            .listRowBackground(Color.secondary)
            
            Section("Acceleration Z") {
                VStack {
                    LineChartView(
                        data: dataReceiverViewModel.session.data.map {
                            ChartData(
                                date: Date(timeIntervalSince1970: $0.timeStamp),
                                data: $0.motion.acceleration.z
                            )
                        }
                    )
                    .padding()
                }
            }
            .listRowBackground(Color.secondary)
        }
        .padding()
        .background(.black)
        .foregroundColor(.orange)
        .scrollContentBackground(.hidden)
    }
}

struct LineChartView<U>: View where U: Dimension {
    let data: [ChartData<U>]
    
    var body: some View {
        Chart {
            ForEach(data, id: \.date) { item in
                LineMark(
                    x: .value("", item.date),
                    y: .value("", item.data.value)
                )
                .interpolationMethod(.stepCenter)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxisLabel(position: .bottom, alignment: .center) {
            Text("Time")
                .foregroundColor(.orange)
        }
        .chartYAxisLabel(position: .top, alignment: .center) {
            Text(data.first?.data.unit.symbol.description ?? "N/A")
                .foregroundColor(.orange)
        }
        .frame(height: 200)
    }
}
