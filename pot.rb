class Blumentopf
  class Pot
    attr_reader :uid, :connected_uid, :position, :hardware_version, :firmware_version, :device_identifier
    def initialize(uid, connected_uid, position, hardware_version, firmware_version, device_identifier)
      @uid = uid
      @connected_uid = connected_uid
      @position = @position
      @hardware_version = hardware_version
      @firmware_version = firmware_version
      @device_identifier = device_identifier
    end
  end
end