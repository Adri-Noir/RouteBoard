// Created with <3 on 02.04.2025.

import MapKit
import SwiftUI

struct MapLocationPickerField: View {
  let title: String
  @Binding var selectedCoordinate: CLLocationCoordinate2D?
  @Binding var errorMessage: String?

  @State private var position: MapCameraPosition
  @State private var searchText: String = ""
  @State private var searchResults: [MKLocalSearchCompletion] = []
  @State private var searchCompleter = MKLocalSearchCompleter()
  @State private var searchCompleterDelegate: SearchCompleterDelegate!
  @State private var isSearching: Bool = false
  @State private var isMapInteractionEnabled: Bool = false

  @FocusState private var isFocused: Bool

  init(
    title: String,
    selectedCoordinate: Binding<CLLocationCoordinate2D?>,
    errorMessage: Binding<String?>,
    initialRegion: MKCoordinateRegion = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 45.8150, longitude: 15.9819),
      span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30)
    )
  ) {
    self.title = title
    self._selectedCoordinate = selectedCoordinate
    self._errorMessage = errorMessage
    self._position = State(initialValue: .region(initialRegion))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)
        .padding(.horizontal, ThemeExtension.horizontalPadding)

      Text("Tap on the map to set the location or search for a specific place.")
        .font(.caption)
        .foregroundColor(Color.gray)
        .padding(.horizontal, ThemeExtension.horizontalPadding)

      // Search bar
      ZStack(alignment: .top) {
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)

          TextField(
            "", text: $searchText,
            prompt: Text("Search for a location...").font(.subheadline).foregroundColor(
              Color.newTextColor.opacity(0.5))
          )
          .focused($isFocused)
          .foregroundColor(Color.newTextColor)
          .autocorrectionDisabled()
          .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty {
              searchResults = []
              isSearching = false
            } else {
              isSearching = true
              searchCompleter.queryFragment = newValue
            }
          }

          if !searchText.isEmpty {
            Button(action: {
              searchText = ""
              searchResults = []
              isSearching = false
            }) {
              Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
            }
          }
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

        // Search results dropdown
        if !searchText.isEmpty && searchResults.isEmpty && isSearching {
          VStack(alignment: .center) {
            Text("No results found")
              .foregroundColor(.gray)
              .font(.subheadline)
              .padding()
          }
          .frame(maxWidth: .infinity)
          .background(Color.white)
          .cornerRadius(10)
          .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 5)
          .offset(y: 55)
        } else if !searchResults.isEmpty {
          ScrollView {
            VStack(alignment: .leading, spacing: 1) {
              ForEach(searchResults, id: \.self) { result in
                Button(action: {
                  searchLocation(for: result)
                }) {
                  VStack(alignment: .leading) {
                    Text(result.title)
                      .foregroundColor(Color.newTextColor)
                      .font(.subheadline)

                    if !result.subtitle.isEmpty {
                      Text(result.subtitle)
                        .foregroundColor(.gray)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                    }
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding()
                  .background(Color.white)
                }
                Divider()
              }
            }
          }
          .background(Color.white)
          .cornerRadius(10)
          .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 5)
          .frame(maxHeight: 200)
          .offset(y: 55)  // Position below the search bar
        }
      }
      .padding(.horizontal, ThemeExtension.horizontalPadding)
      .zIndex(1)  // Ensure dropdown appears above map

      MapReader { proxy in
        ZStack {
          Map(position: $position) {
            if let coordinate = selectedCoordinate {
              Marker("Location", coordinate: coordinate)
                .tint(.red)
            }
          }
          .mapStyle(.standard(elevation: .realistic))
          .frame(height: 300)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
          .onTapGesture { screenCoordinate in
            if isMapInteractionEnabled,
              let mapCoordinate = proxy.convert(screenCoordinate, from: .local)
            {
              selectedCoordinate = mapCoordinate
            }
          }
          .onChange(of: selectedCoordinate) { _, newCoord in
            if let newCoord {
              withAnimation {
                position = .region(
                  MKCoordinateRegion(
                    center: newCoord,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                  )
                )
              }
            }
          }

          if !isMapInteractionEnabled {
            Color.black.opacity(0.4)
              .frame(height: 300)
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .contentShape(Rectangle())
              .overlay(
                Text("Tap to enable map")
                  .foregroundColor(.white)
                  .font(.headline)
                  .padding()
                  .background(Color.black.opacity(0.5))
                  .clipShape(RoundedRectangle(cornerRadius: 8))
              )
              .onTapGesture {
                withAnimation { isMapInteractionEnabled = true }
              }
              .zIndex(2)
          }
        }
        .onTapBackground(enabled: isMapInteractionEnabled) {
          isMapInteractionEnabled = false
        }
      }
      .padding(.horizontal, ThemeExtension.horizontalPadding)
    }
    .onAppear {
      searchCompleterDelegate = SearchCompleterDelegate(
        searchResults: $searchResults, isSearching: $isSearching)
      searchCompleter.delegate = searchCompleterDelegate
      searchCompleter.resultTypes = .pointOfInterest
    }
    .onTapBackground(enabled: isFocused) {
      isFocused = false
    }
  }

  private func searchLocation(for completion: MKLocalSearchCompletion) {
    let searchRequest = MKLocalSearch.Request(completion: completion)
    let search = MKLocalSearch(request: searchRequest)

    search.start { response, error in
      guard let response = response, let mapItem = response.mapItems.first else {
        self.errorMessage = "Location not found"
        self.isSearching = false
        return
      }

      let coordinate = mapItem.placemark.coordinate
      self.selectedCoordinate = coordinate
      self.searchText = ""
      self.searchResults = []
      self.isSearching = false

      withAnimation {
        self.position = .region(
          MKCoordinateRegion(
            center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
          )
        )
      }
    }
  }
}

// Search Completer Delegate
class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
  @Binding var searchResults: [MKLocalSearchCompletion]
  @Binding var isSearching: Bool

  init(searchResults: Binding<[MKLocalSearchCompletion]>, isSearching: Binding<Bool>) {
    self._searchResults = searchResults
    self._isSearching = isSearching
    super.init()
  }

  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    searchResults = completer.results
    isSearching = false
  }

  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    print("Search completer error: \(error.localizedDescription)")
    searchResults = []
    isSearching = false
  }
}

#Preview {
  MapLocationPickerField(
    title: "Location",
    selectedCoordinate: .constant(nil),
    errorMessage: .constant(nil)
  )
}
