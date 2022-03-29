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
import ArcGIS

/// Manages the state for a `FloorFilter`.
@MainActor
final class FloorFilterViewModel: ObservableObject {
    /// Creates a `FloorFilterViewModel`.
    /// - Parameters:
    ///   - automaticSelectionMode: The selection behavior of the floor filter.
    ///   - floorManager: The floor manager used by the `FloorFilterViewModel`.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    init(
        automaticSelectionMode: AutomaticSelectionMode = .always,
        floorManager: FloorManager,
        viewpoint: Binding<Viewpoint?>
    ) {
        self.automaticSelectionMode = automaticSelectionMode
        self.floorManager = floorManager
        self.viewpoint = viewpoint
        
        Task {
            do {
                try await floorManager.load()
                if sites.count == 1,
                    let firstSite = sites.first {
                    // If we have only one site, select it.
                    setSite(firstSite, zoomTo: true)
                }
            } catch {
                print("error: \(error)")
            }
            isLoading = false
        }
    }
    
    // MARK: Published members
    
    /// The currently selected `FloorFacility`.
    @Published
    var selectedFacility: FloorFacility?
    
    /// The currently selected `FloorLevel`.
    @Published
    var selectedLevel: FloorLevel?
    
    /// The currently selected `FloorSite`.
    @Published
    var selectedSite: FloorSite?
    
    /// `true` if the model is loading it's properties, `false` if not loading.
    @Published
    private(set) var isLoading = true
    
    // MARK: Constants
    
    /// The selection behavior of the floor filter.
    private let automaticSelectionMode: AutomaticSelectionMode
    
    /// The `FloorManager` containing the site, floor, and level information.
    let floorManager: FloorManager
    
    // MARK: Public members
    
    /// The floor manager facilities.
    var facilities: [FloorFacility] {
        floorManager.facilities
    }
    
    /// The floor manager levels.
    var levels: [FloorLevel] {
        floorManager.levels
    }
    
    /// The floor manager sites.
    var sites: [FloorSite] {
        floorManager.sites
    }
    
    /// The `Viewpoint` used to pan/zoom to the selected site/facilty.
    /// If `nil`, there will be no automatic pan/zoom operations.
    var viewpoint: Binding<Viewpoint?>
    
    // MARK: Public methods
    
    /// Gets the default level for a facility.
    /// - Parameter facility: The facility to get the default level for.
    /// - Returns: The default level for the facility, which is the level with vertical order 0;
    /// if there's no level with vertical order of 0, it returns the lowest level.
    func defaultLevel(for facility: FloorFacility?) -> FloorLevel? {
        return levels.first(where: { level in
            level.facility == facility && level.verticalOrder == .zero
        }) ?? lowestLevel()
    }
    
    /// Updates the selected site, facility, and level based on a newly selected facility.
    /// - Parameters:
    ///   - floorFacility: The selected facility.
    ///   - zoomTo: The viewpoint should be updated to show to the extent of this facility.
    func setFacility(
        _ floorFacility: FloorFacility?,
        zoomTo: Bool = false
    ) {
        selectedFacility = floorFacility
        if let currentVerticalOrder = selectedLevel?.verticalOrder,
           let newLevel = floorFacility?.levels.first(where: { level in
               level.verticalOrder == currentVerticalOrder
           }) {
            setLevel(newLevel)
        } else {
            setLevel(defaultLevel(for: floorFacility))
        }
        if zoomTo {
            zoomToExtent(extent: floorFacility?.geometry?.extent)
        }
    }
    
    /// Updates the selected site, facility, and level based on a newly selected level.
    /// - Parameter floorLevel: The selected level.
    func setLevel(_ floorLevel: FloorLevel?) {
        selectedLevel = floorLevel
        filterMapToSelectedLevel()
    }
    
    /// Updates the selected site, facility, and level based on a newly selected site.
    /// - Parameters:
    ///   - floorSite: The selected site.
    ///   - zoomTo: The viewpoint should be updated to show to the extent of this site.
    func setSite(
        _ floorSite: FloorSite?,
        zoomTo: Bool = false
    ) {
        selectedSite = floorSite
        if zoomTo {
            zoomToExtent(extent: floorSite?.geometry?.extent)
        }
    }
    
    /// Updates `selectedSite` and `selectedFacility` based on the latest viewpoint position.
    func updateSelection() {
        guard let viewpoint = viewpoint.wrappedValue,
              !viewpoint.targetScale.isZero,
              automaticSelectionMode != .never else {
                  return
        }
        updateSelectedSite()
        updateSelectedFacility()
    }
    
    // MARK: Private methods
    
    /// Sets the visibility of all the levels on the map based on the vertical order of the current selected level.
    private func filterMapToSelectedLevel() {
        guard let selectedLevel = selectedLevel else { return }
        levels.forEach {
            $0.isVisible = $0.verticalOrder == selectedLevel.verticalOrder
        }
    }
    
    /// Returns the level with the lowest vertical order.
    private func lowestLevel() -> FloorLevel? {
        let sortedLevels = levels.sorted {
            $0.verticalOrder < $1.verticalOrder
        }
        return sortedLevels.first {
            $0.verticalOrder != .min && $0.verticalOrder != .max
        }
    }
    
    /// Updates `selectedFacility` if a good selection exists.
    private func updateSelectedFacility() {
        // Only select a facility if it is within minimum scale. Default at 1500.
        let facilityMinScale: Double
        if let minScale = floorManager.facilityLayer?.minScale,
               minScale != .zero {
            facilityMinScale = minScale
        } else {
            facilityMinScale = 1500
        }
        
        if viewpoint.wrappedValue?.targetScale ?? .zero > facilityMinScale {
            return
        }
        
        // If the centerpoint is within a facilities' geometry, select that site.
        let facilityResult = floorManager.facilities.first { facility in
            guard let extent1 = viewpoint.wrappedValue?.targetGeometry.extent,
                  let extent2 = facility.geometry?.extent else {
                return false
            }
            return GeometryEngine.isGeometry(extent1, intersecting: extent2)
        }
        
        if let facilityResult = facilityResult {
            setFacility(facilityResult)
        } else if automaticSelectionMode == .always {
            setFacility(nil)
        }
    }
    
    /// Updates `selectedSite` if a good selection exists.
    private func updateSelectedSite() {
        // Only select a facility if it is within minimum scale. Default at 4300.
        let siteMinScale: Double
        if let minScale = floorManager.siteLayer?.minScale,
               minScale != .zero {
            siteMinScale = minScale
        } else {
            siteMinScale = 4300
        }
        
        // If viewpoint is out of range, reset selection and return early.
        if viewpoint.wrappedValue?.targetScale ?? .zero > siteMinScale {
            if automaticSelectionMode == .always {
                setSite(nil)
                setFacility(nil)
                setLevel(nil)
            }
            return
        }
        
        // If the centerpoint is within a site's geometry, select that site.
        let siteResult = floorManager.sites.first { site in
            guard let extent1 = viewpoint.wrappedValue?.targetGeometry.extent,
                  let extent2 = site.geometry?.extent else {
                return false
            }
            return GeometryEngine.isGeometry(extent1, intersecting: extent2)
        }
        
        if let siteResult = siteResult {
            setSite(siteResult)
        } else if automaticSelectionMode == .always {
            setSite(nil)
        }
    }
    
    /// Updates the viewpoint to display a given extent.
    /// - Parameter extent: The new extent to be shown.
    private func zoomToExtent(extent: Envelope?) {
        // Make sure we have an extent and viewpoint to zoom to.
        guard let extent = extent else {
            return
        }
        let builder = EnvelopeBuilder(envelope: extent)
        builder.expand(factor: 1.5)
        let targetExtent = builder.toGeometry()
        if !targetExtent.isEmpty {
            viewpoint.wrappedValue = Viewpoint(
                targetExtent: targetExtent
            )
        }
    }
}

extension FloorSite: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.name)
    }
}

/// Defines automatic selection behavior.
public enum AutomaticSelectionMode {
    /// Always update selection based on the current viewpoint; clear the selection when the user
    /// navigates away.
    case always
    /// Only update the selection when there is a new site or facility in the current viewpoint; don't clear
    /// selection when the user navigates away.
    case alwaysNotClearing
    /// Never update selection based on the GeoView's current viewpoint.
    case never
}
