"""Static validation only. This does not compile Swift or run XCTest."""
from pathlib import Path
import json
import plistlib
import re
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parent / ".validation-deps"))
from tree_sitter import Language, Parser
import tree_sitter_swift
from openstep_parser import OpenStepDecoder
from PIL import Image


def validate():
    checks = []
    def check(condition, label):
        if not condition:
            raise AssertionError(label)
        checks.append(label)

    parser = Parser(Language(tree_sitter_swift.language()))
    swift_files = sorted(ROOT.rglob("*.swift"))
    for file in swift_files:
        tree = parser.parse(file.read_bytes())
        check(not tree.root_node.has_error, f"Swift syntax: {file.relative_to(ROOT)}")

    project_path = ROOT / "WorldTime.xcodeproj" / "project.pbxproj"
    with project_path.open(encoding="utf-8") as handle:
        project = OpenStepDecoder.ParseFromFile(handle)
    objects = project["objects"]
    check(objects[project["rootObject"]]["isa"] == "PBXProject", "Xcode root project parses")
    root = objects[project["rootObject"]]

    def references(value):
        if isinstance(value, str) and re.fullmatch(r"[A-F0-9]{24}", value):
            yield value
        elif isinstance(value, dict):
            for key, entry in value.items():
                if re.fullmatch(r"[A-F0-9]{24}", key):
                    yield key
                yield from references(entry)
        elif isinstance(value, list):
            for entry in value:
                yield from references(entry)

    check(all(ref in objects for ref in references(project)), "All Xcode object references resolve")
    paths = {}
    def walk(group_id, parent):
        group = objects[group_id]
        base = parent / group.get("path", "")
        for child_id in group.get("children", []):
            child = objects[child_id]
            if child["isa"] == "PBXGroup":
                walk(child_id, base)
            elif child.get("sourceTree") == "<group>":
                path = base / child["path"]
                check(path.exists(), f"Project file exists: {path.relative_to(ROOT)}")
                paths[child_id] = path
    walk(root["mainGroup"], ROOT)

    targets = {objects[key]["name"]: objects[key] for key in root["targets"]}
    check(set(targets) == {"WorldTime", "WorldTimeTests"}, "App and XCTest targets exist")
    for name, source_dir in [("WorldTime", ROOT / "WorldTime"), ("WorldTimeTests", ROOT / "WorldTimeTests")]:
        target = targets[name]
        source_phases = [objects[ref] for ref in target["buildPhases"] if objects[ref]["isa"] == "PBXSourcesBuildPhase"]
        built_paths = [paths[objects[ref]["fileRef"]] for phase in source_phases for ref in phase["files"]]
        check(set(built_paths) == set(source_dir.rglob("*.swift")), f"All {name} Swift files included once")
        check(len(built_paths) == len(set(built_paths)), f"No duplicate compilation in {name}")
    app_resource_phase = next(objects[ref] for ref in targets["WorldTime"]["buildPhases"] if objects[ref]["isa"] == "PBXResourcesBuildPhase")
    resources = {paths[objects[ref]["fileRef"]].name for ref in app_resource_phase["files"]}
    check(resources == {"Assets.xcassets", "PrivacyInfo.xcprivacy"}, "Assets and privacy manifest included")
    check(bool(targets["WorldTimeTests"]["dependencies"]), "Tests depend on app target")

    info = plistlib.loads((ROOT / "WorldTime/Info.plist").read_bytes())
    privacy = plistlib.loads((ROOT / "WorldTime/PrivacyInfo.xcprivacy").read_bytes())
    check(info["CFBundleDisplayName"] == "光影時鐘", "App metadata parses")
    check(privacy["NSPrivacyAccessedAPITypes"][0]["NSPrivacyAccessedAPITypeReasons"] == ["CA92.1"], "UserDefaults declared in privacy manifest")
    check(not any(key.startswith("NSLocation") for key in info), "No location permission needed")
    scheme = ET.parse(ROOT / "WorldTime.xcodeproj/xcshareddata/xcschemes/WorldTime.xcscheme")
    for ref in scheme.iter("BuildableReference"):
        check(ref.attrib["BlueprintIdentifier"] in objects, f"Scheme target resolves: {ref.attrib['BlueprintName']}")
    check(scheme.find("TestAction/Testables/TestableReference") is not None, "Scheme contains test action")
    ET.parse(ROOT / "WorldTime.xcodeproj/project.xcworkspace/contents.xcworkspacedata")

    assets = ROOT / "WorldTime/Assets.xcassets"
    for manifest in sorted(assets.rglob("Contents.json")):
        data = json.loads(manifest.read_text(encoding="utf-8"))
        check(data["info"]["version"] == 1, f"Asset JSON: {manifest.parent.name}")
        for image in data.get("images", []):
            if "filename" in image:
                check((manifest.parent / image["filename"]).exists(), f"Asset file: {image['filename']}")
    for name in ["London", "Taipei", "NewYork"]:
        image = Image.open(assets / f"{name}.imageset/{name}.png")
        check(image.size == (1024, 1536), f"Portrait artwork size: {name}")
        check(image.mode == "RGBA" and image.getpixel((0, 0))[3] == 0, f"Transparent sky preserved: {name}")
    icon = Image.open(assets / "AppIcon.appiconset/AppIcon.png")
    check(icon.size == (1024, 1024) and icon.mode == "RGB", "App icon is 1024px without alpha")

    city_source = (ROOT / "WorldTime/Models/City.swift").read_text(encoding="utf-8")
    ids = re.findall(r'City\(id: "([^"]+)"', city_source)
    check(len(ids) == 27 and len(ids) == len(set(ids)), "27 catalog city IDs are unique")
    test_count = sum(len(re.findall(r"func test\w+\(", path.read_text(encoding="utf-8"))) for path in (ROOT / "WorldTimeTests").glob("*.swift"))
    check(test_count == 26, "26 XCTest methods included (not executed here)")
    check("swift-tools-version: 5.9" in (ROOT / "Package.swift").read_text(encoding="utf-8"), "Swift package manifest included")
    print(json.dumps({"status": "STATIC_CHECKS_PASSED", "checks": len(checks), "swift_files_parsed": len(swift_files),
                      "xcode_objects": len(objects), "xctest_methods_present": test_count,
                      "compiled": False, "xctest_executed": False}, indent=2))
    return checks


if __name__ == "__main__":
    validate()
