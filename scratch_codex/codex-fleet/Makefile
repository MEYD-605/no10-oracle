APP_NAME    := CodexFleet
BUNDLE_ID   := com.laris.codexfleet
BUILD_DIR   := .build
APP_BUNDLE  := $(APP_NAME).app
BINARY      := $(BUILD_DIR)/release/$(APP_NAME)

# ─── Build ───────────────────────────────────────────────

.PHONY: build build-debug run clean install uninstall package launch kill restart

build:
	swift build -c release

build-debug:
	swift build

# ─── Run ─────────────────────────────────────────────────

run: build-debug
	@$(MAKE) kill 2>/dev/null || true
	$(BUILD_DIR)/debug/$(APP_NAME)

launch: package
	@$(MAKE) kill 2>/dev/null || true
	open $(APP_BUNDLE)

restart: kill launch

kill:
	@pkill -x $(APP_NAME) 2>/dev/null || pkill -f "$(APP_NAME).app" 2>/dev/null || true
	@sleep 0.5

# ─── Package (.app bundle) ───────────────────────────────

package: build
	@rm -rf $(APP_BUNDLE)
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@cp $(BINARY) $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
	@# Info.plist
	@/usr/libexec/PlistBuddy -c "Add :CFBundleName string '$(APP_NAME)'" $(APP_BUNDLE)/Contents/Info.plist
	@/usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string '$(APP_NAME)'" $(APP_BUNDLE)/Contents/Info.plist
	@/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string '$(BUNDLE_ID)'" $(APP_BUNDLE)/Contents/Info.plist
	@/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string '1'" $(APP_BUNDLE)/Contents/Info.plist
	@/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string '0.1.0'" $(APP_BUNDLE)/Contents/Info.plist
	@/usr/libexec/PlistBuddy -c "Add :CFBundlePackageType string 'APPL'" $(APP_BUNDLE)/Contents/Info.plist
	@/usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string '$(APP_NAME)'" $(APP_BUNDLE)/Contents/Info.plist
	@/usr/libexec/PlistBuddy -c "Add :LSMinimumSystemVersion string '14.0'" $(APP_BUNDLE)/Contents/Info.plist
	@/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" $(APP_BUNDLE)/Contents/Info.plist
	@/usr/libexec/PlistBuddy -c "Add :NSHighResolutionCapable bool true" $(APP_BUNDLE)/Contents/Info.plist
	@# Ad-hoc sign
	@codesign --force --sign - $(APP_BUNDLE)
	@echo "$(APP_BUNDLE) ready (ad-hoc signed)"

# ─── Install / Uninstall ────────────────────────────────

install: package
	@$(MAKE) kill 2>/dev/null || true
	@rm -rf /Applications/$(APP_BUNDLE)
	@cp -R $(APP_BUNDLE) /Applications/
	@echo "Installed to /Applications/$(APP_BUNDLE)"
	@open /Applications/$(APP_BUNDLE)

uninstall:
	@$(MAKE) kill 2>/dev/null || true
	@rm -rf /Applications/$(APP_BUNDLE)
	@echo "Removed /Applications/$(APP_BUNDLE)"

# ─── Cleanup ─────────────────────────────────────────────

clean:
	swift package clean
	rm -rf $(APP_BUNDLE)
