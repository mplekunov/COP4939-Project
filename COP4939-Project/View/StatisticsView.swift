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
                            data: $0.locationData.directionInDegrees
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
                            data: $0.locationData.coordinate.latitude
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
                            data: $0.locationData.coordinate.longitude
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
                                data: $0.motionData.attitude.pitch
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
                                data: $0.motionData.attitude.yaw
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
                                data: $0.motionData.attitude.roll
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
                                data: $0.motionData.gForce.x
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
                                data: $0.motionData.gForce.y
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
                                data: $0.motionData.gForce.z
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
                                data: $0.motionData.acceleration.x
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
                                data: $0.motionData.acceleration.y
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
                                data: $0.motionData.acceleration.z
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

struct LineChartView: View {
    let data: [ChartData]
    
    var body: some View {
        Chart {
            ForEach(data, id: \.date) { item in
                LineMark(
                    x: .value("", item.date),
                    y: .value("", item.data)
                )
                .interpolationMethod(.stepCenter)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 200)
    }
}
