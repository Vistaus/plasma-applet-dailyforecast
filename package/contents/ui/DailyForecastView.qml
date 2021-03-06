import QtQuick 2.7
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.weather 1.0 as WeatherPlugin

RowLayout {
	id: dailyForecastView
	spacing: units.smallSpacing
	opacity: weatherData.hasData ? 1 : 0
	Behavior on opacity { NumberAnimation { duration: 1000 } }

	readonly property color textColor: plasmoid.configuration.textColor || theme.textColor
	readonly property color outlineColor: plasmoid.configuration.outlineColor || theme.backgroundColor

	readonly property bool showOutline: plasmoid.configuration.showOutline

	readonly property string fontFamily: plasmoid.configuration.fontFamily || theme.defaultFont.family
	readonly property var fontBold: plasmoid.configuration.bold ? Font.Bold : Font.Normal

	readonly property int dateFontSize: plasmoid.configuration.dateFontSize * units.devicePixelRatio
	readonly property int minMaxFontSize: plasmoid.configuration.minMaxFontSize * units.devicePixelRatio

	property alias model: dayRepeater.model
	readonly property real fadedOpacity: 0.7
	readonly property int showNumDays: plasmoid.configuration.showNumDays
	readonly property bool showDailyBackground: plasmoid.configuration.showDailyBackground

	// Note: minItemWidth causes a binding loop
	readonly property int minItemWidth: {
		var minWidth = 0
		for (var i = 0; i < dayRepeater.count; i++) {
			var item = dayRepeater.itemAt(i)
			if (!item.visible) {
				continue
			}
			if (i == 0 || item.width < minWidth) {
				minWidth = item.width
			}
		}
		return minWidth
	}

	Repeater {
		id: dayRepeater
		model: weatherData.dailyForecastModel

		Item {
			id: dayItem
			implicitWidth: dayItemLayout.implicitWidth + frame.margins.horizontal
			implicitHeight: dayItemLayout.implicitHeight + frame.margins.vertical
			Layout.fillWidth: true
			Layout.fillHeight: true

			visible: {
				if (dailyForecastView.showNumDays == 0) { // Show all
					return true
				} else {
					return (index+1) <= dailyForecastView.showNumDays
				}
			}

			PlasmaCore.FrameSvgItem {
				id: frame
				anchors.fill: parent
				visible: dailyForecastView.showDailyBackground
				imagePath: visible ? "widgets/background" : ""
			}

			ColumnLayout {
				id: dayItemLayout
				anchors.fill: parent
				anchors.leftMargin: frame.margins.left
				anchors.rightMargin: frame.margins.right
				anchors.topMargin: frame.margins.top
				anchors.bottomMargin: frame.margins.bottom
				spacing: 0

				PlasmaComponents.Label {
					text: modelData.dayLabel || ""

					opacity: dailyForecastView.fadedOpacity

					font.pointSize: -1
					font.pixelSize: dailyForecastView.dateFontSize
					font.family: dailyForecastView.fontFamily
					font.weight: dailyForecastView.fontBold
					color: dailyForecastView.textColor
					style: dailyForecastView.showOutline ? Text.Outline : Text.Normal
					styleColor: dailyForecastView.outlineColor
					Layout.alignment: Qt.AlignHCenter
				}

				PlasmaCore.IconItem {
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.maximumWidth: dailyForecastView.minItemWidth
					Layout.maximumHeight: dailyForecastView.minItemWidth
					Layout.alignment: Qt.AlignCenter
					source: modelData.forecastIcon
					roundToIconSize: false
					width: parent.width * 1.2
					height: parent.width * 1.2

					// Rectangle { anchors.fill: parent; color: "transparent"; border.width: 1; border.color: "#f00"}
				}

				RowLayout {
					Layout.alignment: Qt.AlignHCenter
					spacing: units.smallSpacing

					PlasmaComponents.Label {
						readonly property var value: modelData.tempHigh

						readonly property bool hasValue: !isNaN(value)
						text: hasValue ? i18n("%1°", value) : ""
						visible: hasValue
						font.pointSize: -1
						font.pixelSize: dailyForecastView.minMaxFontSize
						font.family: dailyForecastView.fontFamily
						font.weight: dailyForecastView.fontBold
						color: dailyForecastView.textColor
						style: dailyForecastView.showOutline ? Text.Outline : Text.Normal
						styleColor: dailyForecastView.outlineColor
						Layout.alignment: Qt.AlignHCenter
					}

					PlasmaComponents.Label {
						readonly property var value: modelData.tempLow
						opacity: dailyForecastView.fadedOpacity

						readonly property bool hasValue: !isNaN(value)
						text: hasValue ? i18n("%1°", value) : ""
						visible: hasValue
						font.pointSize: -1
						font.pixelSize: dailyForecastView.minMaxFontSize
						font.family: dailyForecastView.fontFamily
						font.weight: dailyForecastView.fontBold
						color: dailyForecastView.textColor
						style: dailyForecastView.showOutline ? Text.Outline : Text.Normal
						styleColor: dailyForecastView.outlineColor
						Layout.alignment: Qt.AlignHCenter
					}
				}

				// Top align contents
				Item {
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
			}

			PlasmaCore.ToolTipArea {
				anchors.fill: parent
				mainText: modelData.forecastLabel
			}

		}
	}

}
