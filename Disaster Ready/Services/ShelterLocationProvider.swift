import CoreLocation
import Observation

@MainActor
@Observable
final class ShelterLocationProvider: NSObject, CLLocationManagerDelegate {
    private(set) var coordinate: ShelterCoordinate?
    private(set) var error: ShelterLocationError?
    private(set) var isRequesting = false

    @ObservationIgnored private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// Called only from the explicit "Use my location" action.
    func requestOneLocation() {
        coordinate = nil
        error = nil
        isRequesting = true

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            isRequesting = false
            error = .permissionUnavailable
        @unknown default:
            isRequesting = false
            error = .locationUnavailable
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor [weak self] in
            guard let self else { return }
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .denied, .restricted:
                isRequesting = false
                error = .permissionUnavailable
            case .notDetermined:
                break
            @unknown default:
                isRequesting = false
                error = .locationUnavailable
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = Self.validatedCoordinate(from: locations.last) else {
            Task { @MainActor [weak self] in
                self?.isRequesting = false
                self?.error = .locationUnavailable
            }
            return
        }
        Task { @MainActor [weak self] in
            self?.coordinate = coordinate
            self?.isRequesting = false
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            self?.isRequesting = false
            self?.error = .locationUnavailable
        }
    }

    nonisolated static func validatedCoordinate(from location: CLLocation?) -> ShelterCoordinate? {
        guard let location else { return nil }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        guard
            latitude.isFinite,
            longitude.isFinite,
            (-90...90).contains(latitude),
            (-180...180).contains(longitude)
        else {
            return nil
        }
        return ShelterCoordinate(latitude: latitude, longitude: longitude)
    }
}

enum ShelterLocationError: Equatable {
    case permissionUnavailable
    case locationUnavailable
}
