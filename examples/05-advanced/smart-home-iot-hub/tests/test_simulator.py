"""
Tests for Device Simulator
VibeCoding ID 013
"""
import pytest
from simulator.device_simulator import (
    TemperatureSensor, HumiditySensor, SmartSwitch, DeviceSimulator
)
from simulator.mqtt_client import SimpleMQTTClient
from unittest.mock import Mock, MagicMock, patch

class TestTemperatureSensor:
    """Test temperature sensor"""

    def test_initialization(self):
        sensor = TemperatureSensor()
        assert sensor.device_type == "temperature_sensor"
        assert sensor.current_value == 22.0

    def test_update(self):
        sensor = TemperatureSensor(min_temp=15, max_temp=30)
        data = sensor.update()
        
        assert "device_id" in data
        assert "value" in data
        assert data["unit"] == "°C"
        assert 15 <= data["value"] <= 30

    def test_value_clamping(self):
        sensor = TemperatureSensor(min_temp=20, max_temp=25)
        sensor.current_value = 18  # Below min
        data = sensor.update()
        assert data["value"] >= 20

    def test_get_payload(self):
        sensor = TemperatureSensor()
        payload = sensor.get_payload()
        assert isinstance(payload, str)
        assert "temperature_sensor" in payload


class TestHumiditySensor:
    """Test humidity sensor"""

    def test_initialization(self):
        sensor = HumiditySensor()
        assert sensor.device_type == "humidity_sensor"

    def test_update(self):
        sensor = HumiditySensor(min_hum=30, max_hum=80)
        data = sensor.update()
        
        assert data["unit"] == "%"
        assert 30 <= data["value"] <= 80

    def test_get_payload(self):
        sensor = HumiditySensor()
        payload = sensor.get_payload()
        assert "humidity_sensor" in payload


class TestSmartSwitch:
    """Test smart switch"""

    def test_initialization(self):
        switch = SmartSwitch("Light", "home/lights/living_room")
        assert switch.device_type == "switch"
        assert switch.current_value == False

    def test_toggle(self):
        switch = SmartSwitch("Light", "home/lights/living_room")
        assert switch.current_value == False
        
        switch.toggle()
        assert switch.current_value == True
        
        switch.toggle()
        assert switch.current_value == False

    def test_update(self):
        switch = SmartSwitch("AC", "home/ac/living_room")
        data = switch.update()
        
        assert data["state"] == "OFF"
        switch.toggle()
        data = switch.update()
        assert data["state"] == "ON"


class TestDeviceSimulator:
    """Test device simulator orchestrator"""

    def test_initialization(self):
        mock_mqtt = Mock()
        simulator = DeviceSimulator(mock_mqtt)
        
        assert len(simulator.devices) == 0
        assert simulator.running == False

    def test_add_device(self):
        mock_mqtt = Mock()
        simulator = DeviceSimulator(mock_mqtt)
        
        sensor = TemperatureSensor()
        simulator.add_device(sensor)
        
        assert len(simulator.devices) == 1
        assert sensor.device_id in simulator.devices

    def test_get_device_list(self):
        mock_mqtt = Mock()
        simulator = DeviceSimulator(mock_mqtt)
        
        simulator.add_device(TemperatureSensor())
        simulator.add_device(SmartSwitch("Light", "home/lights/living_room"))
        
        device_list = simulator.get_device_list()
        assert len(device_list) == 2
        assert all("type" in d for d in device_list.values())

    def test_publish_device_data(self):
        mock_mqtt = Mock()
        mock_mqtt.publish.return_value = True
        
        simulator = DeviceSimulator(mock_mqtt)
        sensor = TemperatureSensor()
        simulator.add_device(sensor)
        
        result = simulator.publish_device_data(sensor.device_id)
        
        assert result == True
        mock_mqtt.publish.assert_called_once()

    def test_publish_all_devices(self):
        mock_mqtt = Mock()
        mock_mqtt.publish.return_value = True
        
        simulator = DeviceSimulator(mock_mqtt)
        simulator.add_device(TemperatureSensor())
        simulator.add_device(HumiditySensor())
        simulator.add_device(SmartSwitch("Light", "home/lights/living_room"))
        
        count = simulator.publish_all_devices()
        
        assert count == 3
        assert mock_mqtt.publish.call_count == 3
