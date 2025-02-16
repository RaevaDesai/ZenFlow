import SwiftUI

import MapKit

import CoreLocation



struct LocationView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region: MKCoordinateRegion
    @State private var locations: [MapLocation] = []
    @State private var selectedLocation: MapLocation?

    private var isLocationAuthorized: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
    }


    init() {
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5485, longitude: -121.9886),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        ))
    }

    var body: some View {
        VStack {
            if isLocationAuthorized {
                mapView
                    .overlay(selectedLocationOverlay, alignment: .bottom)
            } else {
                locationPermissionView
            }
        }
        .onAppear(perform: onAppear)
        .onChange(of: locationManager.lastLocation, perform: onLocationChange)
    }

    private var mapView: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                LocationAnnotationView(location: location)
                    .onTapGesture {
                        withAnimation {
                            selectedLocation = location
                            zoomToLocation(location)
                        }
                    }
            }
        }
    }
    private func zoomToLocation(_ location: MapLocation) {
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    private var selectedLocationOverlay: some View {

        selectedLocation.map { location in

            VStack {

                Text(location.name)

                    .font(.headline)

                Text(location.type.rawValue)

                    .font(.subheadline)

            }

            .padding()

            .background(Color.white.opacity(0.8))

            .cornerRadius(10)

            .padding(.bottom)

        }

    }



    private var locationPermissionView: some View {

        VStack {

            Text("This app needs your location to show nearby wellness spots.")

                .padding()

            Button("Allow Location Access") {

                locationManager.requestPermission()

            }

            .padding()

            .background(Color.blue)

            .foregroundColor(.white)

            .cornerRadius(10)

        }

    }



    private func onAppear() {

        locationManager.requestPermission()

        loadSampleLocations()

        if let location = locationManager.lastLocation {

            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))

        }

    }



    private func onLocationChange(_ newLocation: CLLocation?) {

        if let location = newLocation {

            region.center = location.coordinate

        }

    }



    private func loadSampleLocations() {

        locations = [

            MapLocation(name: "Fremont Hospital", coordinate: CLLocationCoordinate2D(latitude: 37.5503, longitude: -121.9844), type: .mentalHospital),

            MapLocation(name: "New Start Recovery Solutions", coordinate: CLLocationCoordinate2D(latitude: 37.5344, longitude: -121.9892), type: .mentalHospital),

            MapLocation(name: "Bodhi Mental Health", coordinate: CLLocationCoordinate2D(latitude: 37.5486, longitude: -121.9886), type: .therapyPlace),

            MapLocation(name: "Kaiser Permanente Mental Health and Wellness", coordinate: CLLocationCoordinate2D(latitude: 37.5509, longitude: -121.9785), type: .therapyPlace),

            MapLocation(name: "Crestwood Treatment Center", coordinate: CLLocationCoordinate2D(latitude: 37.5477, longitude: -121.9885), type: .mentalHospital),

            MapLocation(name: "Crestwood Manor", coordinate: CLLocationCoordinate2D(latitude: 37.5479, longitude: -121.9887), type: .mentalHospital)

        ]

    }

}



struct LocationAnnotationView: View {

    let location: MapLocation



    var body: some View {

        VStack {

            ZStack {

                Circle()

                    .fill(location.color)

                    .frame(width: 30, height: 30)

                Image(systemName: location.type == .mentalHospital ? "brain.head.profile" : "leaf.fill")

                    .foregroundColor(.white)

                    .font(.system(size: 15))

            }

            Text(location.name)

                .font(.caption)

                .foregroundColor(.black)

                .fontWeight(.bold)

                .padding(5)

                .background(Color.white.opacity(0.7))

                .cornerRadius(5)

        }

    }

}



class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()

    @Published var lastLocation: CLLocation?

    @Published var authorizationStatus: CLAuthorizationStatus?



    override init() {

        super.init()

        locationManager.delegate = self

        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.distanceFilter = kCLDistanceFilterNone

        locationManager.startUpdatingLocation()

    }



    func requestPermission() {

        locationManager.requestWhenInUseAuthorization()

    }



    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        lastLocation = locations.last

    }



    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        authorizationStatus = manager.authorizationStatus

    }

}



struct MapLocation: Identifiable {

    let id = UUID()

    let name: String

    let coordinate: CLLocationCoordinate2D

    let type: LocationType

    var color: Color {

        switch type {

        case .therapyPlace: return .blue

        case .mentalHospital: return .green

        }

    }

}



enum LocationType: String {

    case therapyPlace = "Therapy Place"

    case mentalHospital = "Mental Hospital"

}
