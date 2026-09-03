package com.baseflow.geolocator.location;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.location.LocationManager;

import org.junit.Test;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class LocationManagerClientTest {

  @Test
  public void determineProvider_prefersGpsWhenForced() {
    LocationManager locationManager = mock(LocationManager.class);
    when(locationManager.getProviders(true))
        .thenReturn(
            Arrays.asList(LocationManager.FUSED_PROVIDER, LocationManager.GPS_PROVIDER));

    String provider =
        LocationManagerClient.determineProvider(
            locationManager, LocationAccuracy.best, true);

    assertEquals(LocationManager.GPS_PROVIDER, provider);
  }

  @Test
  public void determineProvider_fallsBackWhenGpsIsUnavailable() {
    LocationManager locationManager = mock(LocationManager.class);
    when(locationManager.getProviders(true))
        .thenReturn(Collections.singletonList(LocationManager.NETWORK_PROVIDER));

    String provider =
        LocationManagerClient.determineProvider(
            locationManager, LocationAccuracy.best, true);

    assertEquals(LocationManager.NETWORK_PROVIDER, provider);
  }

  @Test
  public void determineProvider_preservesPassiveProviderForLowestAccuracy() {
    LocationManager locationManager = mock(LocationManager.class);
    when(locationManager.getProviders(true))
        .thenReturn(
            Arrays.asList(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER));

    String provider =
        LocationManagerClient.determineProvider(
            locationManager, LocationAccuracy.lowest, false);

    assertEquals(LocationManager.PASSIVE_PROVIDER, provider);
  }

  @Test
  public void createLocationClient_usesLocationManagerWhenGpsIsForced() {
    Context context = mock(Context.class);
    when(context.getSystemService(Context.LOCATION_SERVICE))
        .thenReturn(mock(LocationManager.class));
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("forceGpsProvider", true);
    LocationOptions options = LocationOptions.parseArguments(arguments);

    LocationClient client =
        GeolocationManager.getInstance().createLocationClient(context, false, options);

    assertTrue(client instanceof LocationManagerClient);
  }
}
