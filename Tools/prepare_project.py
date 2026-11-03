"""Reproducibly create the dependency-free Xcode project and asset manifests."""
from pathlib import Path
import hashlib
import json
import math
import shutil
import sys
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "WorldTime"
ASSETS = APP / "Assets.xcassets"


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def assets(source_directory):
    sources = {
        "London": "exec-43b9ba6e-d073-40f4-9833-bb8870d2a814.png",
        "Taipei": "exec-0ccca337-6ead-46e5-b6c4-5886c0f09a94.png",
        "NewYork": "exec-afdf79e2-bb17-4a38-88ae-76b960c21c2d.png",
    }
    write_json(ASSETS / "Contents.json", {"info": {"author": "xcode", "version": 1}})
    for name, source in sources.items():
        directory = ASSETS / f"{name}.imageset"
        directory.mkdir(parents=True, exist_ok=True)
        target = directory / f"{name}.png"
        if source_directory:
            shutil.copyfile(Path(source_directory) / source, target)
        if not target.exists():
            raise FileNotFoundError(f"Missing illustration: {target}")
        write_json(directory / "Contents.json", {
            "images": [{"filename": target.name, "idiom": "universal"}],
            "info": {"author": "xcode", "version": 1},
            "properties": {"preserves-vector-representation": False},
        })
    for name, color in [("LaunchBackground", (11, 17, 27)), ("AccentColor", (229, 188, 139))]:
        write_json(ASSETS / f"{name}.colorset" / "Contents.json", {
            "colors": [{"idiom": "universal", "color": {"color-space": "srgb", "components": {
                "red": f"{color[0]/255:.6f}", "green": f"{color[1]/255:.6f}",
                "blue": f"{color[2]/255:.6f}", "alpha": "1.000"}}}],
            "info": {"author": "xcode", "version": 1}})

    # A simple code-native icon: a horizon through a half-lit clock / sun.
    icon = Image.new("RGB", (1024, 1024))
    pixels = icon.load()
    for y in range(1024):
        t = y / 1023
        for x in range(1024):
            glow = max(0, 1 - math.hypot((x - 700) / 1000, (y - 360) / 900))
            pixels[x, y] = (int(17 + 24 * t + 13 * glow), int(29 + 22 * t + 11 * glow), int(48 + 27 * t + 13 * glow))
    draw = ImageDraw.Draw(icon)
    draw.ellipse((222, 190, 802, 770), fill=(225, 190, 145))
    draw.pieslice((222, 190, 802, 770), 90, 270, fill=(66, 86, 111))
    draw.ellipse((222, 190, 802, 770), outline=(237, 211, 175), width=6)
    draw.line([(512, 322), (512, 480), (632, 550)], fill=(249, 239, 219), width=19)
    draw.ellipse((496, 464, 528, 496), fill=(249, 239, 219))
    draw.rectangle((145, 672, 879, 676), fill=(237, 211, 175))
    for index, height in enumerate([45, 78, 59, 114, 83, 135, 68, 99, 54]):
        x = 260 + index * 57
        draw.rectangle((x, 810-height, x+39, 810), fill=(138, 160, 183))
    directory = ASSETS / "AppIcon.appiconset"
    directory.mkdir(parents=True, exist_ok=True)
    icon.save(directory / "AppIcon.png")
    write_json(directory / "Contents.json", {
        "images": [{"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
        "info": {"author": "xcode", "version": 1}})


def identifier(name):
    return hashlib.sha1(name.encode()).hexdigest()[:24].upper()


def openstep(value, depth=0):
    prefix = "\t" * depth
    if isinstance(value, dict):
        return "{\n" + "".join(f"{prefix}\t{json.dumps(k)} = {openstep(v, depth+1)};\n" for k, v in value.items()) + prefix + "}"
    if isinstance(value, list):
        return "(\n" + "".join(f"{prefix}\t{openstep(v, depth+1)},\n" for v in value) + prefix + ")"
    return json.dumps(str(value), ensure_ascii=False)


def project():
    objects = {}

    def obj(object_key, isa, **values):
        key = identifier(object_key)
        objects[key] = {"isa": isa, **values}
        return key

    source_files = sorted(APP.rglob("*.swift"))
    test_files = sorted((ROOT / "WorldTimeTests").glob("*.swift"))
    file_refs = {}
    for path in source_files + test_files:
        file_refs[path] = obj(str(path.relative_to(ROOT)), "PBXFileReference", lastKnownFileType="sourcecode.swift", path=path.name, sourceTree="<group>")
    groups = []
    for name in ["Models", "Store", "Theme", "Views"]:
        children = [file_refs[p] for p in source_files if p.parent.name == name]
        groups.append(obj("group-"+name, "PBXGroup", children=children, path=name, sourceTree="<group>"))
    resource_refs = []
    for name, kind in [("Assets.xcassets", "folder.assetcatalog"), ("PrivacyInfo.xcprivacy", "text.xml")]:
        resource_refs.append(obj(name, "PBXFileReference", lastKnownFileType=kind, path=name, sourceTree="<group>"))
    info_ref = obj("Info.plist", "PBXFileReference", lastKnownFileType="text.plist.xml", path="Info.plist", sourceTree="<group>")
    app_group = obj("app-group", "PBXGroup", children=[file_refs[p] for p in source_files if p.parent == APP]+groups+resource_refs+[info_ref], path="WorldTime", sourceTree="<group>")
    test_group = obj("test-group", "PBXGroup", children=[file_refs[p] for p in test_files], path="WorldTimeTests", sourceTree="<group>")
    app_product = obj("app-product", "PBXFileReference", explicitFileType="wrapper.application", includeInIndex=0, path="WorldTime.app", sourceTree="BUILT_PRODUCTS_DIR")
    test_product = obj("test-product", "PBXFileReference", explicitFileType="wrapper.cfbundle", includeInIndex=0, path="WorldTimeTests.xctest", sourceTree="BUILT_PRODUCTS_DIR")
    product_group = obj("products", "PBXGroup", children=[app_product, test_product], name="Products", sourceTree="<group>")
    root_group = obj("root-group", "PBXGroup", children=[app_group, test_group, product_group], sourceTree="<group>")

    def phase(name, isa, files):
        build_files = [obj(name+"-"+ref, "PBXBuildFile", fileRef=ref) for ref in files]
        return obj(name, isa, buildActionMask=2147483647, files=build_files, runOnlyForDeploymentPostprocessing=0)

    app_phases = [phase("app-sources", "PBXSourcesBuildPhase", [file_refs[p] for p in source_files]),
                  phase("app-frameworks", "PBXFrameworksBuildPhase", []),
                  phase("app-resources", "PBXResourcesBuildPhase", resource_refs)]
    test_phases = [phase("test-sources", "PBXSourcesBuildPhase", [file_refs[p] for p in test_files]),
                   phase("test-frameworks", "PBXFrameworksBuildPhase", []),
                   phase("test-resources", "PBXResourcesBuildPhase", [])]

    common = {"ALWAYS_SEARCH_USER_PATHS": "NO", "CLANG_ENABLE_MODULES": "YES", "CLANG_ENABLE_OBJC_ARC": "YES",
              "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES", "CLANG_WARN_UNREACHABLE_CODE": "YES",
              "COPY_PHASE_STRIP": "NO", "ENABLE_STRICT_OBJC_MSGSEND": "YES", "GCC_C_LANGUAGE_STANDARD": "gnu17",
              "IPHONEOS_DEPLOYMENT_TARGET": "17.0", "SDKROOT": "iphoneos", "SWIFT_VERSION": "5.0"}
    app_settings = {"ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon", "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "CODE_SIGN_STYLE": "Automatic", "CURRENT_PROJECT_VERSION": "1", "MARKETING_VERSION": "1.0",
                    "GENERATE_INFOPLIST_FILE": "NO", "INFOPLIST_FILE": "WorldTime/Info.plist",
                    "PRODUCT_BUNDLE_IDENTIFIER": "com.example.LightAndTime", "PRODUCT_NAME": "$(TARGET_NAME)",
                    "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks"],
                    "SWIFT_EMIT_LOC_STRINGS": "YES", "TARGETED_DEVICE_FAMILY": "1,2",
                    "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator", "SUPPORTS_MACCATALYST": "NO"}
    test_settings = {"BUNDLE_LOADER": "$(TEST_HOST)", "CODE_SIGN_STYLE": "Automatic", "GENERATE_INFOPLIST_FILE": "YES",
                     "PRODUCT_BUNDLE_IDENTIFIER": "com.example.LightAndTime.Tests", "PRODUCT_NAME": "$(TARGET_NAME)",
                     "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/WorldTime.app/WorldTime", "TARGETED_DEVICE_FAMILY": "1,2",
                     "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks", "@loader_path/Frameworks"]}

    def configs(name, base):
        refs = []
        for config in ["Debug", "Release"]:
            settings = dict(base)
            if name == "project":
                settings.update({"DEBUG_INFORMATION_FORMAT": "dwarf" if config == "Debug" else "dwarf-with-dsym",
                                 "SWIFT_OPTIMIZATION_LEVEL": "-Onone" if config == "Debug" else "-O"})
                if config == "Debug":
                    settings.update({"ENABLE_TESTABILITY": "YES", "GCC_OPTIMIZATION_LEVEL": "0", "ONLY_ACTIVE_ARCH": "YES", "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG $(inherited)"})
                else:
                    settings.update({"SWIFT_COMPILATION_MODE": "wholemodule", "VALIDATE_PRODUCT": "YES"})
            refs.append(obj(name+config, "XCBuildConfiguration", buildSettings=settings, name=config))
        return obj(name+"-configs", "XCConfigurationList", buildConfigurations=refs, defaultConfigurationIsVisible=0, defaultConfigurationName="Release")

    project_configs = configs("project", common)
    app_configs = configs("app", app_settings)
    test_configs = configs("test", test_settings)
    app_target = obj("app-target", "PBXNativeTarget", buildConfigurationList=app_configs, buildPhases=app_phases,
                     buildRules=[], dependencies=[], name="WorldTime", productName="WorldTime", productReference=app_product, productType="com.apple.product-type.application")
    proxy = obj("test-proxy", "PBXContainerItemProxy", containerPortal=identifier("project"), proxyType=1, remoteGlobalIDString=app_target, remoteInfo="WorldTime")
    dependency = obj("test-dependency", "PBXTargetDependency", target=app_target, targetProxy=proxy)
    test_target = obj("test-target", "PBXNativeTarget", buildConfigurationList=test_configs, buildPhases=test_phases,
                      buildRules=[], dependencies=[dependency], name="WorldTimeTests", productName="WorldTimeTests", productReference=test_product, productType="com.apple.product-type.bundle.unit-test")
    project_id = obj("project", "PBXProject", attributes={"BuildIndependentTargetsInParallel": "YES", "LastSwiftUpdateCheck": "1500", "LastUpgradeCheck": "1500", "TargetAttributes": {app_target: {"CreatedOnToolsVersion": "15.0"}, test_target: {"CreatedOnToolsVersion": "15.0", "TestTargetID": app_target}}},
                     buildConfigurationList=project_configs, compatibilityVersion="Xcode 14.0", developmentRegion="zh_TW", hasScannedForEncodings=0,
                     knownRegions=["en", "Base", "zh_TW"], mainGroup=root_group, productRefGroup=product_group, projectDirPath="", projectRoot="", targets=[app_target, test_target])
    output = ROOT / "WorldTime.xcodeproj"
    output.mkdir(exist_ok=True)
    (output / "project.pbxproj").write_text("// !$*UTF8*$!\n"+openstep({"archiveVersion": 1, "classes": {}, "objectVersion": 56, "objects": objects, "rootObject": project_id})+"\n", encoding="utf-8")
    workspace = output / "project.xcworkspace"
    workspace.mkdir(exist_ok=True)
    (workspace / "contents.xcworkspacedata").write_text('<?xml version="1.0" encoding="UTF-8"?>\n<Workspace version="1.0"><FileRef location="self:"></FileRef></Workspace>\n', encoding="utf-8")
    scheme_dir = output / "xcshareddata" / "xcschemes"
    scheme_dir.mkdir(parents=True, exist_ok=True)
    app_ref = f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{app_target}" BuildableName="WorldTime.app" BlueprintName="WorldTime" ReferencedContainer="container:WorldTime.xcodeproj"/>'
    test_ref = f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{test_target}" BuildableName="WorldTimeTests.xctest" BlueprintName="WorldTimeTests" ReferencedContainer="container:WorldTime.xcodeproj"/>'
    (scheme_dir / "WorldTime.xcscheme").write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1500" version="1.3">
  <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries>
    <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{app_ref}</BuildActionEntry>
  </BuildActionEntries></BuildAction>
  <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
    <Testables><TestableReference skipped="NO">{test_ref}</TestableReference></Testables>
  </TestAction>
  <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
    <BuildableProductRunnable runnableDebuggingMode="0">{app_ref}</BuildableProductRunnable>
  </LaunchAction>
  <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{app_ref}</BuildableProductRunnable></ProfileAction>
  <AnalyzeAction buildConfiguration="Debug"/>
  <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
''', encoding="utf-8")


if __name__ == "__main__":
    assets(sys.argv[1] if len(sys.argv) > 1 else None)
    project()
    print("Xcode project and asset catalogs prepared.")
