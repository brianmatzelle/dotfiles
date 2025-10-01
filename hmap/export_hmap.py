#!/usr/bin/env python3
"""
HMAP Export Utility
Exports HMAP Protocol memories to JSON for sharing/backup.
"""

from hmap_visualizer import export_hmap_to_json
import json

# Current HMAP tree (as of 2025-10-01)
CURRENT_HMAP = {
    "[L0.INDEX] ROOT": """
    LOGICAL_ADDR: 0x0008
    PHYSICAL_ADDR: 9496496
    PARENT_PTR: NULL
    CHILD_PTRS: [0x0009 (HMAP Protocol), 0x000A (Ada Project), 0x000F (Address Translation Table)]
    CONTENT: Master index for all hierarchical memories. Entry point for context traversal. PERSISTENT WORKSPACE: This tree grows organically across sessions and projects.
    """,
    
    "[L0.PROTOCOL] HMAP Protocol": """
    LOGICAL_ADDR: 0x0009
    PHYSICAL_ADDR: 9496491
    PARENT_PTR: 0x0008
    CHILD_PTRS: [0x0011 (Autonomous Checklist)]
    CONTENT: Hierarchical Memory Access Protocol - AUTONOMOUS SELF-ORGANIZATION. Check first, then act. Memory is PERSISTENT across sessions.
    """,
    
    "[L0.CHECKLIST] Autonomous Checklist": """
    LOGICAL_ADDR: 0x0011
    PHYSICAL_ADDR: 9497008
    PARENT_PTR: 0x0009
    CHILD_PTRS: NULL
    CONTENT: HMAP autonomous update trigger signals. SESSION START: Call print_memory_map(), check if project exists, then act. Never assume tree is empty.
    """,
    
    "[SYSTEM] Address Translation Table": """
    LOGICAL_ADDR: 0x000F
    PHYSICAL_ADDR: 9496762
    PARENT_PTR: NULL
    CHILD_PTRS: NULL
    CONTENT: Maps logical addresses to physical memory IDs. Always update with every new memory creation.
    """,
}


def main():
    """Export HMAP Protocol to JSON."""
    
    print("Exporting HMAP Protocol to JSON...")
    print("=" * 60)
    
    # Export to JSON
    json_output = export_hmap_to_json(CURRENT_HMAP)
    
    # Save to file
    output_file = "hmap_protocol_export.json"
    with open(output_file, "w") as f:
        f.write(json_output)
    
    print(f"✅ Exported to {output_file}")
    print()
    print("Preview:")
    print(json_output[:500] + "...")
    print()
    print("To import in another system:")
    print("  from hmap_visualizer import import_hmap_from_json")
    print(f"  with open('{output_file}') as f:")
    print("      memories = import_hmap_from_json(f.read())")


if __name__ == "__main__":
    main()

