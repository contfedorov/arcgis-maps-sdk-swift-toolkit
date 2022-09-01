// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import Charts

/// A view displaying details for popup media.
struct LineChart: View {
    /// The chart data to display.
    let chartData: [ChartData]

    var body: some View {
        if #available(iOS 16, *) {
            Group {
                Chart(chartData) {
                    LineMark(
                        x: .value("Field", $0.label),
                        y: .value("Value", $0.value)
                    )
                    PointMark(
                        x: .value("Field", $0.label),
                        y: .value("Value", $0.value)
                    )
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel(collisionResolution: .greedy, orientation: .verticalReversed)
                    }
                }
            }
        }
    }
}
