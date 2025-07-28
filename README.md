# Home Assistant Motion-Triggered Camera Analysis

An advanced Home Assistant integration that combines motion detection, automated camera snapshots, AI-powered image analysis, and intelligent notifications with GIF creation capabilities. I created this blueprint as I wanted a lighter-weight blueprint than the standard LLMVision blueprint, and I also wanted to ensure it only fired when motion-related triggers occured, rather than just motion itself (IE, only run if the Person or Animal detection is triggered and motion is also triggered ). Even more, I wanted my notifications to include a gif of the detection rather than a single frame.

## Features

- **Multi-Snapshot Capture**: Takes 3-8 sequential snapshots when motion is detected
- **AI-Powered Analysis**: Uses LLM Vision to analyze image sequences and provide intelligent descriptions
- **Smart Notifications**: Sends rich notifications with animated GIFs to mobile devices
- **Cooldown Protection**: Prevents notification spam with configurable cooldown periods
- **Snooze Functionality**: Allows users to pause notifications for 2 hours
- **Animated GIFs**: Creates motion sequences as GIFs for better context
- **Multi-Device Support**: Supports multiple mobile devices with individual pause controls

## Requirements

### Home Assistant Add-ons/Integrations
- [LLM Vision](https://github.com/valentinfrlch/ha-llmvision) - For AI image analysis
- Mobile App integration - For notifications
- Camera integration - For your security cameras

### System Dependencies
- ImageMagick - For GIF creation (automatically installed via script)
- Shell command capability in Home Assistant

## Installation

### 1. Install Required Integrations

Install the LLM Vision integration through HACS or manually:
```
https://github.com/valentinfrlch/ha-llmvision
```

### 2. Set Up Shell Command

Add the following to your `configuration.yaml`:

```yaml
shell_command:
  create_motion_gif: 'bash /config/scripts/create_motion_gif.sh "{{ snapshot_folder }}" "{{ num_snapshots }}" "{{ output_gif }}" "{{ gif_delay }}"'
```

### 3. Install the GIF Creation Script

1. Create the scripts directory if it doesn't exist:
   ```bash
   mkdir -p /config/scripts
   ```

2. Copy `create_motion_gif.sh` to `/config/scripts/create_motion_gif.sh`

3. Make it executable:
   ```bash
   chmod +x /config/scripts/create_motion_gif.sh
   ```

### 4. Create Pause Helper Entities (Optional)

For each mobile device you want to support snooze functionality, create input boolean helpers:

```yaml
input_boolean:
  pause_notifications_device1:
    name: "Pause Notifications - Device 1"
    initial: false
  pause_notifications_device2:
    name: "Pause Notifications - Device 2"
    initial: false
```

### 5. Import Blueprints

1. **Main Motion Detection Blueprint**: Import `analyze-snapshots-with-ai.yaml`
2. **Notification Handler Blueprint**: Import `Motion-Notification-Handler.yaml`

## Configuration

### Motion Detection Automation

1. Go to **Settings** → **Automations & Scenes** → **Blueprints**
2. Find "Motion-Triggered Camera Snapshot + Analysis (Enhanced)"
3. Click **Create Automation**

#### Required Configuration:
- **Camera**: Select your camera entity
- **Motion Sensors**: Choose one or more motion sensors
- **Provider**: Select your LLM Vision provider configuration
- **Model**: Choose AI model (default: gpt-4o)
- **Mobile Devices**: Select devices for notifications

#### Optional Configuration:
- **Number of Snapshots**: 3-8 images (default: 3)
- **Snapshot Interval**: 500-3000ms between shots (default: 700ms)
- **Custom LLM Prompt**: Override default analysis prompt
- **Snapshot Path**: Where to save images (default: `/config/www/snapshots`)
- **Pause Helpers**: Input boolean entities for snooze functionality
- **Cooldown Duration**: Prevent spam (default: 300 seconds)
- **Notification Color**: RGB color for notifications

### Notification Handler Automation

1. Import the "Motion Camera Notification Actions Handler" blueprint
2. Configure with the same pause helper entities used in the main automation

## Usage

### How It Works

1. **Motion Detection**: When any configured motion sensor triggers
2. **Camera Verification**: Checks if the camera's motion sensor is also active
3. **Snapshot Sequence**: Takes multiple snapshots at configured intervals
4. **GIF Creation**: Combines snapshots into an animated GIF
5. **AI Analysis**: Sends images to LLM Vision for intelligent analysis
6. **Smart Notifications**: Sends notification with GIF and analysis to mobile devices

### Notification Features

Each notification includes:
- **Animated GIF**: Shows the motion sequence
- **AI Description**: Intelligent analysis of what was detected
- **Live View Button**: Opens camera feed directly
- **Snooze Option**: Pause notifications for 2 hours (if configured)

### Example AI Prompts

The default prompt focuses on detecting people, animals, and vehicles. You can customize it for specific needs:

```
Analyze this motion sequence and describe any people, animals, or vehicles. Focus on actions, descriptions, and movement direction. Be concise and mention the most important details first. If this appears to be a false alarm with no significant activity, respond with "Nothing of note detected - False Alarm".
```

## File Structure

```
/config/
├── scripts/
│   └── create_motion_gif.sh          # GIF creation script
├── blueprints/automation/
│   ├── analyze-snapshots-with-ai.yaml    # Main motion detection
│   └── Motion-Notification-Handler.yaml  # Notification actions
└── www/snapshots/                     # Generated snapshots and GIFs
    └── [camera_name]/
        └── [sensor_name]/
            ├── snapshot_1.jpg
            ├── snapshot_2.jpg
            ├── snapshot_3.jpg
            └── motion_sequence.gif
```

## Customization

### Custom Analysis Prompts

Tailor the AI analysis for specific use cases:

**Pet Detection**:
```
Focus on identifying pets and their activities. Describe the type of animal, its actions, and any interesting behaviors. Ignore human activity unless they're interacting with pets.
```

**Security Focused**:
```
Analyze for security concerns. Describe any people, vehicles, or unusual activities. Note the time of day context and whether activities seem normal or suspicious. Be detailed about person descriptions and vehicle types.
```

**Package Detection**:
```
Look for delivery personnel, packages, or vehicles. Describe delivery activities, package placement, and any interactions with the property.
```

### Notification Customization

Modify notification behavior by adjusting:
- Colors and icons based on detection type
- Custom notification channels
- Different notification priorities
- Additional action buttons

## Troubleshooting

### Common Issues

**GIFs Not Creating**:
- Check ImageMagick installation: `apk add imagemagick`
- Verify script permissions: `chmod +x /config/scripts/create_motion_gif.sh`
- Check shell command configuration in `configuration.yaml`

**AI Analysis Not Working**:
- Verify LLM Vision integration is installed and configured
- Check provider credentials and model availability
- Review Home Assistant logs for LLM Vision errors

**Notifications Not Received**:
- Confirm Mobile App integration is working
- Check notification settings on mobile devices
- Verify device IDs match in automation configuration

**False Alarms**:
- Adjust motion sensor sensitivity
- Fine-tune AI prompt to better filter false positives
- Increase cooldown duration

### Debug Mode

Enable debug logging for troubleshooting:

```yaml
logger:
  default: info
  logs:
    custom_components.llmvision: debug
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly with different camera and motion sensor combinations
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [LLM Vision Integration](https://github.com/valentinfrlch/ha-llmvision) for AI analysis capabilities
- Home Assistant community for blueprint architecture
- ImageMagick for GIF processing

## Support

For issues and feature requests, please use the GitHub Issues page. When reporting issues, include:
- Home Assistant version
- Integration versions
- Relevant log entries
- Configuration details (remove sensitive information)