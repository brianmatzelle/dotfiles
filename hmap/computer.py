from fastmcp import FastMCP
from fastmcp.server.proxy import ProxyClient
from uuid import uuid4
from typing import Dict
from hmap_visualizer import visualize_hmap, find_memory_distance, export_hmap_to_json, import_hmap_from_json

app = FastMCP()

memory = -1
@app.tool
def get_memory_address():
    """Allocate a unique logical memory address (sequential integer)."""
    global memory
    memory += 1
    return memory

@app.tool
def generate_uuid():
    """Generate a random UUID v4 string."""
    return str(uuid4())

@app.tool
def print_memory_map(memories: Dict[str, str]):
    """
    Visualize the HMAP memory tree structure.
    
    Args:
        memories: Dictionary mapping memory titles to their content strings.
                  Each memory should contain HMAP-formatted fields:
                  - LOGICAL_ADDR: hex address (e.g., 0x0008)
                  - PHYSICAL_ADDR: numeric memory ID
                  - PARENT_PTR: logical address of parent (or NULL)
                  - CHILD_PTRS: list of child logical addresses
                  - CONTENT: memory content
    
    Returns:
        Formatted tree visualization showing hierarchy and address mappings.
    
    Example:
        memories = {
            "[L0.INDEX] ROOT": "LOGICAL_ADDR: 0x0008\\nPHYSICAL_ADDR: 9496496...",
            "[L1.INDEX] Project": "LOGICAL_ADDR: 0x000A\\nPARENT_PTR: 0x0008..."
        }
    """
    return visualize_hmap(memories)

@app.tool
def find_path_between_memories(memories: Dict[str, str], addr1: str, addr2: str):
    """
    Find the path and distance between two memory nodes in the HMAP tree.
    Useful for understanding how far apart two contexts are.
    
    Args:
        memories: Dictionary mapping memory titles to their content strings (HMAP format)
        addr1: First logical address (e.g., "0x0008")
        addr2: Second logical address (e.g., "0x0010")
    
    Returns:
        Path analysis including:
        - Distance (number of hops)
        - Relationship description (parent/child, siblings, cousins, etc.)
        - Common ancestor
        - Visual path representation
    
    Example:
        result = find_path_between_memories(memories, "0x0010", "0x000C")
        # Shows path from ChatInterface to Branding node
    """
    return find_memory_distance(memories, addr1, addr2)

@app.tool
def export_hmap_protocol(memories: Dict[str, str], filename: str = "hmap_export.json"):
    """
    Export HMAP tree structure to JSON file for backup, sharing, or version control.
    
    Args:
        memories: Dictionary mapping memory titles to their content strings (HMAP format)
        filename: Output filename (default: "hmap_export.json")
    
    Returns:
        Success message with file path and node count
    
    Use cases:
        - Backup HMAP structure before major changes
        - Share protocol definitions with others
        - Version control memory trees
        - System migration and bootstrapping
    
    Example:
        result = export_hmap_protocol(memories, "my_project_backup.json")
        # Creates my_project_backup.json in current directory
    """
    import os
    
    json_output = export_hmap_to_json(memories)
    
    # Write to file
    with open(filename, 'w') as f:
        f.write(json_output)
    
    # Get absolute path
    abs_path = os.path.abspath(filename)
    
    # Count nodes
    import json
    data = json.loads(json_output)
    node_count = len(data.get('nodes', []))
    
    return f"✅ Exported {node_count} nodes to {abs_path}"

@app.tool
def import_hmap_protocol(filename: str):
    """
    Import HMAP tree structure from JSON file to restore or bootstrap a memory system.
    
    Args:
        filename: Path to JSON file containing HMAP structure (from export_hmap_protocol)
    
    Returns:
        Dictionary mapping memory titles to their content strings in HMAP format.
        Can be used directly with other HMAP tools or to recreate memories.
    
    Use cases:
        - Restore from backup
        - Bootstrap new system with existing HMAP structure
        - Import shared protocol definitions
        - Migrate between systems
    
    Example:
        memories = import_hmap_protocol("hmap_backup.json")
        # Use with print_memory_map(memories) to visualize
    """
    import os
    
    # Check if file exists
    if not os.path.exists(filename):
        return {"error": f"File not found: {filename}"}
    
    # Read file
    with open(filename, 'r') as f:
        json_data = f.read()
    
    # Import and return memories
    return import_hmap_from_json(json_data)

if __name__ == "__main__":
  app.run(transport="http", port=8000)