//  Mapbox GL JS bridge (Flutter Web <-> Mapbox GL JS) 
// Depends on: los_banos_boundary.js  (exposes losBanosGeoJSON)

var _mapboxInstances = {};


    /**
     * Initialises a Mapbox GL JS map locked to the Los BaÃ±os boundary.
     * Called from Dart via dart:js after the HtmlElementView is mounted.
     */
    function initMapbox(containerId, accessToken) {
      if (_mapboxInstances[containerId]) {
        _mapboxInstances[containerId].resize();
        return;
      }

      if (!accessToken || accessToken === '') {
        console.error('[Mapbox] Access token is empty. Run with --dart-define-from-file=.env');
        return;
      }

     
      var attempts = 0;
      var maxAttempts = 40;
      function tryInit() {
        var el = document.getElementById(containerId)
          || (function() {
               var all = document.querySelectorAll('flt-platform-view-slot, flt-platform-view');
               for (var i = 0; i < all.length; i++) {
                 var found = all[i].shadowRoot && all[i].shadowRoot.getElementById(containerId);
                 if (found) return found;
               }
               return null;
             })();

        if (!el) {
          if (++attempts < maxAttempts) { setTimeout(tryInit, 150); }
          else { console.error('[Mapbox] Container #' + containerId + ' not found after ' + maxAttempts + ' attempts.'); }
          return;
        }

        // Compute bounds from polygon
        var coords = losBanosGeoJSON.features[0].geometry.coordinates[0];
        var minLng = Infinity, maxLng = -Infinity, minLat = Infinity, maxLat = -Infinity;
        coords.forEach(function(c) {
          if (c[0] < minLng) minLng = c[0];
          if (c[0] > maxLng) maxLng = c[0];
          if (c[1] < minLat) minLat = c[1];
          if (c[1] > maxLat) maxLat = c[1];
        });

        var pad = 0.005;
        var bounds = [
          [minLng - pad, minLat - pad],
          [maxLng + pad, maxLat + pad]
        ];
        var center = [(minLng + maxLng) / 2, (minLat + maxLat) / 2];

        mapboxgl.accessToken = accessToken;

        var map = new mapboxgl.Map({
          container: el,
          style: 'mapbox://styles/mapbox/streets-v12',
          center: center,
          zoom: 13,
          pitch: 45,
          maxBounds: bounds,
          maxZoom: 18
        });

        map.addControl(new mapboxgl.NavigationControl());
        map.addControl(new mapboxgl.FullscreenControl());

        // Compute bounds once – reused by fitBounds and fitMapboxBounds
        var lngLatBounds = coords.reduce(function(b, coord) {
          return b.extend(coord);
        }, new mapboxgl.LngLatBounds(coords[0], coords[0]));

        map._losBanosBounds = lngLatBounds;

        var maskGeoJSON = {
          "type": "FeatureCollection",
          "features": [{
            "type": "Feature",
            "properties": {},
            "geometry": {
              "type": "Polygon",
              "coordinates": [
                [[-180, -90], [180, -90], [180, 90], [-180, 90], [-180, -90]],
                coords
              ]
            }
          }]
        };

        /**
         * Adds all custom sources and layers to the map.
         * Must be called after every style load (initial + style switches).
         */
        function addCustomLayers() {
          // 3D terrain
          if (!map.getSource('mapbox-dem')) {
            map.addSource('mapbox-dem', {
              type: 'raster-dem',
              url: 'mapbox://mapbox.mapbox-terrain-dem-v1',
              tileSize: 512,
              maxzoom: 14
            });
          }
          map.setTerrain({ source: 'mapbox-dem', exaggeration: 1.5 });

          // 3D buildings – insert below the first symbol (label) layer
          var layers = map.getStyle().layers;
          var labelLayerId;
          for (var i = 0; i < layers.length; i++) {
            if (layers[i].type === 'symbol' && layers[i].layout['text-field']) {
              labelLayerId = layers[i].id;
              break;
            }
          }
          if (!map.getLayer('3d-buildings')) {
            map.addLayer({
              id: '3d-buildings',
              source: 'composite',
              'source-layer': 'building',
              filter: ['==', 'extrude', 'true'],
              type: 'fill-extrusion',
              minzoom: 15,
              paint: {
                'fill-extrusion-color': '#aaa',
                'fill-extrusion-height': ['get', 'height'],
                'fill-extrusion-base': ['get', 'min_height'],
                'fill-extrusion-opacity': 0.6
              }
            }, labelLayerId);
          }

          // Los Baños GeoJSON boundary source
          if (!map.getSource('los-banos')) {
            map.addSource('los-banos', { type: 'geojson', data: losBanosGeoJSON });
          }

          // World mask with Los Baños cut out as a hole
          if (!map.getSource('mask')) {
            map.addSource('mask', { type: 'geojson', data: maskGeoJSON });
          }
          if (!map.getLayer('mask-layer')) {
            map.addLayer({
              id: 'mask-layer',
              type: 'fill',
              source: 'mask',
              paint: { 'fill-color': '#000000', 'fill-opacity': 0.85 }
            });
          }

          // Boundary outline
          if (!map.getLayer('los-banos-outline')) {
            map.addLayer({
              id: 'los-banos-outline',
              type: 'line',
              source: 'los-banos',
              paint: { 'line-color': '#000', 'line-width': 2 }
            });
          }

          // Ensure mask visibility follows the map instance state (defaults to hidden)
          if (typeof map._maskVisible === 'undefined') map._maskVisible = false;
          var vis = map._maskVisible ? 'visible' : 'none';
          if (map.getLayer('mask-layer')) map.setLayoutProperty('mask-layer', 'visibility', vis);
          if (map.getLayer('los-banos-outline')) map.setLayoutProperty('los-banos-outline', 'visibility', vis);
        }

        // Initial load – add layers and fit bounds
        map.on('load', function() {
          addCustomLayers();

          function updateMinZoom() {
            var camera = map.cameraForBounds(lngLatBounds, { padding: 20 });
            if (camera && camera.zoom != null) map.setMinZoom(camera.zoom);
          }
          updateMinZoom();
          map.fitBounds(lngLatBounds, { padding: 20 });
          map.on('resize', updateMinZoom);
        });

        // Re-add layers every time the style is swapped
        map.on('style.load', function() {
          addCustomLayers();
        });

        _mapboxInstances[containerId] = map;

        // Automatically resize the Mapbox canvas whenever the container
        // element changes size (e.g. window resize, panel collapse, etc.)
        if (typeof ResizeObserver !== 'undefined') {
          var ro = new ResizeObserver(function() {
            map.resize();
          });
          ro.observe(el);
          map._resizeObserver = ro;
        }
      } // end tryInit
      tryInit();
    }

    /** Changes the base style of an existing map instance. */
    function setMapboxStyle(containerId, style) {
      if (_mapboxInstances[containerId]) {
        _mapboxInstances[containerId].setStyle(style);
      }
    }

    /** Flies the camera to new coordinates (within the allowed bounds). */
    function flyMapboxTo(containerId, lng, lat, zoom) {
      if (_mapboxInstances[containerId]) {
        _mapboxInstances[containerId].flyTo({ center: [lng, lat], zoom: zoom });
      }
    }
  
    /** Forces a resize on an existing map (call after Flutter layout changes). */
    function resizeMapboxMap(containerId) {
      if (_mapboxInstances[containerId]) {
        _mapboxInstances[containerId].resize();
      }
    }

    /** Resizes the map canvas then flies back to fit the Los Baños boundary. */
    function fitMapboxBounds(containerId) {
      var map = _mapboxInstances[containerId];
      if (!map) return;
      map.resize();
      if (map._losBanosBounds) {
        map.fitBounds(map._losBanosBounds, { padding: 20, duration: 800 });
      }
    }

    /** Removes and destroys a map instance. */
    function removeMapboxMap(containerId) {
      var map = _mapboxInstances[containerId];
      if (map) {
        if (map._resizeObserver) map._resizeObserver.disconnect();
        map.remove();
        delete _mapboxInstances[containerId];
      }
    }
    
    /** Show or hide the Los Baños mask + outline for a map instance. */
    function setMaskVisible(containerId, visible) {
      var map = _mapboxInstances[containerId];
      if (!map) return;
      map._maskVisible = !!visible;
      var vis = map._maskVisible ? 'visible' : 'none';
      if (map.getLayer && map.getLayer('mask-layer')) {
        try { map.setLayoutProperty('mask-layer', 'visibility', vis); } catch (e) {}
      }
      if (map.getLayer && map.getLayer('los-banos-outline')) {
        try { map.setLayoutProperty('los-banos-outline', 'visibility', vis); } catch (e) {}
      }
    }

    /** Toggle the mask visibility on/off. */
    function toggleMask(containerId) {
      var map = _mapboxInstances[containerId];
      if (!map) return;
      setMaskVisible(containerId, !map._maskVisible);
    }

    // ── Emergency report markers ──────────────────────────────────────────────

    /** Injects the pulse-keyframe CSS once into the document. */
    (function _injectMarkerStyles() {
      if (document.getElementById('_mapbox_marker_styles')) return;
      var style = document.createElement('style');
      style.id = '_mapbox_marker_styles';
      style.textContent = [
        '@keyframes markerPulse {',
        '  0%   { box-shadow: 0 0 0 0 rgba(255,255,255,0.6), 0 2px 8px rgba(0,0,0,0.4); }',
        '  70%  { box-shadow: 0 0 0 10px rgba(255,255,255,0), 0 2px 8px rgba(0,0,0,0.4); }',
        '  100% { box-shadow: 0 0 0 0 rgba(255,255,255,0), 0 2px 8px rgba(0,0,0,0.4); }',
        '}',
        '.em-marker { transition: transform 0.15s; }',
        '.em-marker:hover { transform: scale(1.25); }'
      ].join('\n');
      document.head.appendChild(style);
    })();

    /** Returns the fill colour for a given emergency type string. */
    function _markerFill(type) {
      switch (type) {
        case 'fire':    return '#EF4444';
        case 'medical': return '#3B82F6';
        case 'police':  return '#8B5CF6';
        case 'flood':   return '#0EA5E9';
        default:        return '#F59E0B';
      }
    }

    /**
     * Replaces all emergency markers on the map.
     * @param {string}  containerId  – the map container DOM id
     * @param {string}  markersJson  – JSON array of
     *   { id, lat, lng, type, status, address } objects
     *
     * Clicks call window._mapboxMarkerClick(reportId) so Dart can react.
     */
    function setEmergencyMarkers(containerId, markersJson) {
      var map = _mapboxInstances[containerId];
      if (!map) return;

      // Remove previous markers
      if (!map._emergencyMarkers) map._emergencyMarkers = [];
      map._emergencyMarkers.forEach(function(m) { m.remove(); });
      map._emergencyMarkers = [];

      var markers;
      try { markers = JSON.parse(markersJson); } catch (e) { return; }

      markers.forEach(function(data) {
        var color   = _markerFill(data.type);
        var resolved = data.status === 'resolved';

        // Outer glow ring (status tint)
        var ring = document.createElement('div');
        ring.style.cssText = [
          'width:32px', 'height:32px',
          'border-radius:50%',
          'display:flex', 'align-items:center', 'justify-content:center',
          'background:' + (resolved ? 'rgba(120,120,120,0.25)' : color.replace(')', ',0.25)').replace('rgb', 'rgba')),
          'cursor:pointer',
          'position:relative'
        ].join(';');

        // Inner filled dot
        var dot = document.createElement('div');
        dot.className = 'em-marker';
        dot.style.cssText = [
          'width:18px', 'height:18px',
          'border-radius:50%',
          'background:' + color,
          'border:2.5px solid white',
          'box-shadow:0 2px 8px rgba(0,0,0,0.45)',
          'opacity:' + (resolved ? '0.55' : '1')
        ].join(';');
        if (data.status === 'active') {
          dot.style.animation = 'markerPulse 1.8s ease-in-out infinite';
        }
        ring.appendChild(dot);

        // Tooltip via native title
        ring.title = '[' + data.id + '] ' + data.type.toUpperCase() + '\n' + (data.address || '');

        ring.addEventListener('click', function(e) {
          e.stopPropagation();
          if (typeof window._mapboxMarkerClick === 'function') {
            window._mapboxMarkerClick(data.id);
          }
        });

        var marker = new mapboxgl.Marker({ element: ring, anchor: 'center' })
          .setLngLat([data.lng, data.lat])
          .addTo(map);

        map._emergencyMarkers.push(marker);
      });
    }

    /** Removes all emergency markers from the map without replacing them. */
    function clearEmergencyMarkers(containerId) {
      var map = _mapboxInstances[containerId];
      if (!map || !map._emergencyMarkers) return;
      map._emergencyMarkers.forEach(function(m) { m.remove(); });
      map._emergencyMarkers = [];
    }
    // 
