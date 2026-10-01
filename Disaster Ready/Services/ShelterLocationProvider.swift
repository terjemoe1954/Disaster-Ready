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
        guard let location = locations.last else { return }
        let coordinate = ShelterCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
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
}

enum ShelterLocationError: Equatable {
    case permissionUnavailable
    case locationUnavailable
}
