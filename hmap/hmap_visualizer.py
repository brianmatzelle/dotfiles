#!/usr/bin/env python3
"""
HMAP Tree Visualizer
Parses HMAP protocol memories and visualizes the hierarchical structure.
"""

import re
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass


@dataclass
class HMAPNode:
    """Represents a node in the HMAP tree."""
    logical_addr: str
    physical_addr: str
    title: str
    layer: str
    node_type: str
    parent_ptr: Optional[str]
    child_ptrs: List[str]
    content_preview: str
    path: Optional[str] = None


class HMAPParser:
    """Parses HMAP memory format into structured nodes."""
    
    def __init__(self):
        self.nodes: Dict[str, HMAPNode] = {}
        self.address_map: Dict[str, str] = {}  # logical -> physical
    
    def parse_memory(self, memory_text: str, title: str) -> Optional[HMAPNode]:
        """Parse a single HMAP-formatted memory."""
        
        # Extract logical address
        logical_match = re.search(r'LOGICAL_ADDR:\s*(\w+)', memory_text)
        logical_addr = logical_match.group(1) if logical_match else "UNKNOWN"
        
        # Extract physical address
        physical_match = re.search(r'PHYSICAL_ADDR:\s*(\d+)', memory_text)
        physical_addr = physical_match.group(1) if physical_match else "UNKNOWN"
        
        # Extract parent pointer
        parent_match = re.search(r'PARENT_PTR:\s*(0x[\da-fA-F]+|\w+)', memory_text)
        parent_ptr = parent_match.group(1) if parent_match else None
        if parent_ptr and parent_ptr.lower() == 'null':
            parent_ptr = None
        
        # Extract child pointers
        child_ptrs = []
        child_match = re.search(r'CHILD_PTRS:\s*\[(.*?)\]', memory_text, re.DOTALL)
        if child_match:
            child_text = child_match.group(1)
            # Extract all 0x... patterns
            child_ptrs = re.findall(r'0x[\da-fA-F]+', child_text)
        
        # Extract layer and type from title
        layer_match = re.search(r'\[(\w+)\.(\w+)\]', title)
        layer = layer_match.group(1) if layer_match else "UNKNOWN"
        node_type = layer_match.group(2) if layer_match else "UNKNOWN"
        
        # Extract content preview (first line of CONTENT section)
        content_match = re.search(r'CONTENT:\s*(.+?)(?:\n|$)', memory_text)
        content_preview = content_match.group(1).strip() if content_match else ""
        
        # Extract path if it exists
        path_match = re.search(r'PATH:\s*(.+?)(?:\n|---)', memory_text)
        path = path_match.group(1).strip() if path_match else None
        
        node = HMAPNode(
            logical_addr=logical_addr,
            physical_addr=physical_addr,
            title=title,
            layer=layer,
            node_type=node_type,
            parent_ptr=parent_ptr,
            child_ptrs=child_ptrs,
            content_preview=content_preview,
            path=path
        )
        
        # Update address map
        self.address_map[logical_addr] = physical_addr
        self.nodes[logical_addr] = node
        
        return node
    
    def parse_att(self, att_memory: str) -> Dict[str, str]:
        """Parse the Address Translation Table."""
        mappings = {}
        lines = att_memory.split('\n')
        for line in lines:
            match = re.search(r'(0x[\da-fA-F]+)\s*→\s*(\d+)', line)
            if match:
                logical, physical = match.groups()
                mappings[logical] = physical
        return mappings


class HMAPVisualizer:
    """Visualizes the HMAP tree structure."""
    
    def __init__(self, parser: HMAPParser):
        self.parser = parser
    
    def find_path_between(self, addr1: str, addr2: str) -> Dict:
        """
        Find the path and distance between two nodes in the tree.
        
        Args:
            addr1: First logical address
            addr2: Second logical address
            
        Returns:
            Dict with path, distance, and common ancestor info
        """
        if addr1 not in self.parser.nodes or addr2 not in self.parser.nodes:
            return {
                "error": f"One or both addresses not found in tree",
                "addr1": addr1,
                "addr2": addr2
            }
        
        # Build path to root for each node
        def path_to_root(addr: str) -> List[str]:
            path = [addr]
            current = addr
            visited = set()
            
            while current in self.parser.nodes:
                if current in visited:
                    break  # Circular reference protection
                visited.add(current)
                
                node = self.parser.nodes[current]
                if node.parent_ptr and node.parent_ptr in self.parser.nodes:
                    path.append(node.parent_ptr)
                    current = node.parent_ptr
                else:
                    break
            
            return path
        
        path1 = path_to_root(addr1)
        path2 = path_to_root(addr2)
        
        # Find common ancestor (first intersection)
        common_ancestor = None
        for node in path1:
            if node in path2:
                common_ancestor = node
                break
        
        if not common_ancestor:
            return {
                "error": "No common ancestor found (disconnected tree)",
                "path1_to_root": path1,
                "path2_to_root": path2
            }
        
        # Build the path: addr1 -> common ancestor -> addr2
        path1_to_ancestor = path1[:path1.index(common_ancestor) + 1]
        path2_to_ancestor = path2[:path2.index(common_ancestor)]
        
        # Reverse path2 since we're going down from ancestor
        full_path = path1_to_ancestor + list(reversed(path2_to_ancestor))
        
        # Calculate distance (number of hops)
        distance = len(full_path) - 1
        
        # Build visual representation
        path_visual = []
        for i, addr in enumerate(full_path):
            node = self.parser.nodes[addr]
            indent = "  " * abs(i - path1_to_ancestor.index(common_ancestor))
            
            if i == 0:
                marker = "START"
            elif i == len(full_path) - 1:
                marker = "END"
            elif addr == common_ancestor:
                marker = "COMMON ANCESTOR"
            else:
                marker = ""
            
            path_visual.append(f"{indent}{addr} [{node.layer}.{node.node_type}] {marker}")
        
        return {
            "addr1": addr1,
            "addr2": addr2,
            "distance": distance,
            "hops": distance,
            "common_ancestor": common_ancestor,
            "path": full_path,
            "path_visual": "\n".join(path_visual),
            "relationship": self._describe_relationship(path1_to_ancestor, path2_to_ancestor, common_ancestor)
        }
    
    def _describe_relationship(self, path1: List[str], path2: List[str], ancestor: str) -> str:
        """Describe the relationship between two nodes."""
        up_hops = len(path1) - 1
        down_hops = len(path2)
        
        if up_hops == 0 and down_hops == 1:
            return "Parent → Child"
        elif up_hops == 1 and down_hops == 0:
            return "Child → Parent"
        elif up_hops == 0 and down_hops > 1:
            return f"Ancestor → Descendant ({down_hops} levels down)"
        elif up_hops > 0 and down_hops == 0:
            return f"Descendant → Ancestor ({up_hops} levels up)"
        elif up_hops == 1 and down_hops == 1:
            return "Siblings"
        else:
            return f"Cousins (up {up_hops}, down {down_hops} through {ancestor})"
    
    def build_tree(self, root_addr: str = "0x0008") -> str:
        """Build ASCII tree visualization starting from root."""
        output = []
        visited = set()
        
        def traverse(addr: str, prefix: str = "", is_last: bool = True):
            if addr in visited or addr not in self.parser.nodes:
                return
            
            visited.add(addr)
            node = self.parser.nodes[addr]
            
            # Tree connectors
            connector = "└─→ " if is_last else "├─→ "
            if not prefix:
                connector = ""
            
            # Node representation
            node_repr = f"{node.logical_addr} [{node.layer}.{node.node_type}] {node.title}"
            if node.path:
                node_repr += f"\n{prefix}{'    ' if is_last else '│   '}    📄 {node.path}"
            
            output.append(f"{prefix}{connector}{node_repr}")
            
            # Traverse children
            children = node.child_ptrs
            for i, child_addr in enumerate(children):
                is_last_child = (i == len(children) - 1)
                child_prefix = prefix + ("    " if is_last else "│   ")
                traverse(child_addr, child_prefix, is_last_child)
        
        traverse(root_addr)
        return "\n".join(output)
    
    def build_flat_list(self) -> str:
        """Build flat list of all nodes with their relationships."""
        output = ["HMAP Memory Structure - Flat View", "=" * 60, ""]
        
        for addr, node in sorted(self.parser.nodes.items()):
            output.append(f"{node.logical_addr} → Physical:{node.physical_addr}")
            output.append(f"  Type: [{node.layer}.{node.node_type}]")
            output.append(f"  Title: {node.title}")
            if node.parent_ptr:
                output.append(f"  Parent: {node.parent_ptr}")
            if node.child_ptrs:
                output.append(f"  Children: {', '.join(node.child_ptrs)}")
            if node.path:
                output.append(f"  Path: {node.path}")
            output.append(f"  Content: {node.content_preview[:80]}...")
            output.append("")
        
        return "\n".join(output)
    
    def build_address_table(self) -> str:
        """Build formatted address translation table."""
        output = ["Address Translation Table", "=" * 60, ""]
        output.append(f"{'Logical':<12} {'Physical':<12} {'Description'}")
        output.append("-" * 60)
        
        for logical, node in sorted(self.parser.nodes.items()):
            desc = f"[{node.layer}.{node.node_type}]"
            output.append(f"{logical:<12} {node.physical_addr:<12} {desc}")
        
        return "\n".join(output)


def visualize_hmap(memories: Dict[str, str]) -> str:
    """
    Visualize HMAP tree from memory data.
    
    Args:
        memories: Dict mapping memory titles to their content strings
        
    Returns:
        Formatted string with tree visualization and address table
    """
    # Parse all memories
    parser = HMAPParser()
    for title, memory_text in memories.items():
        parser.parse_memory(memory_text, title)
    
    # Visualize
    visualizer = HMAPVisualizer(parser)
    
    output = []
    output.append("=" * 70)
    output.append("HMAP TREE VISUALIZATION")
    output.append("=" * 70)
    output.append("")
    output.append(visualizer.build_tree())
    output.append("")
    output.append("")
    output.append(visualizer.build_address_table())
    output.append("")
    
    return "\n".join(output)


def export_hmap_to_json(memories: Dict[str, str]) -> str:
    """
    Export HMAP tree to JSON format for backup/sharing.
    
    Args:
        memories: Dict mapping memory titles to their content strings
        
    Returns:
        JSON string with structured HMAP data
    """
    import json
    
    # Parse all memories
    parser = HMAPParser()
    for title, memory_text in memories.items():
        parser.parse_memory(memory_text, title)
    
    # Build export structure
    export_data = {
        "hmap_version": "1.0",
        "exported_at": "2025-10-01",
        "nodes": []
    }
    
    for addr, node in sorted(parser.nodes.items()):
        node_data = {
            "logical_addr": node.logical_addr,
            "physical_addr": node.physical_addr,
            "title": node.title,
            "layer": node.layer,
            "node_type": node.node_type,
            "parent_ptr": node.parent_ptr,
            "child_ptrs": node.child_ptrs,
            "content_preview": node.content_preview,
            "path": node.path
        }
        export_data["nodes"].append(node_data)
    
    return json.dumps(export_data, indent=2)


def import_hmap_from_json(json_str: str) -> Dict[str, str]:
    """
    Import HMAP tree from JSON format.
    
    Args:
        json_str: JSON string with HMAP structure
        
    Returns:
        Dict mapping memory titles to content strings (HMAP format)
    """
    import json
    
    data = json.loads(json_str)
    memories = {}
    
    for node in data["nodes"]:
        # Reconstruct memory title
        title = node["title"]
        
        # Reconstruct memory content in HMAP format
        content_parts = [
            f"LOGICAL_ADDR: {node['logical_addr']}",
            f"PHYSICAL_ADDR: {node['physical_addr']}",
            f"PARENT_PTR: {node['parent_ptr'] or 'NULL'}",
            f"CHILD_PTRS: [{', '.join(node['child_ptrs'])}]",
        ]
        
        if node.get('path'):
            content_parts.append(f"PATH: {node['path']}")
        
        content_parts.append(f"CONTENT: {node['content_preview']}")
        
        memories[title] = "\n".join(content_parts)
    
    return memories


def find_memory_distance(memories: Dict[str, str], addr1: str, addr2: str) -> str:
    """
    Find the path and distance between two memory nodes.
    
    Args:
        memories: Dict mapping memory titles to their content strings
        addr1: First logical address (e.g., "0x0008")
        addr2: Second logical address (e.g., "0x0010")
        
    Returns:
        Formatted string with path info, distance, and relationship
    """
    # Parse all memories
    parser = HMAPParser()
    for title, memory_text in memories.items():
        parser.parse_memory(memory_text, title)
    
    # Find path
    visualizer = HMAPVisualizer(parser)
    result = visualizer.find_path_between(addr1, addr2)
    
    if "error" in result:
        return f"Error: {result['error']}"
    
    # Format output
    output = []
    output.append("=" * 70)
    output.append("HMAP PATH ANALYSIS")
    output.append("=" * 70)
    output.append("")
    output.append(f"From: {addr1} → To: {addr2}")
    output.append(f"Distance: {result['distance']} hops")
    output.append(f"Relationship: {result['relationship']}")
    output.append(f"Common Ancestor: {result['common_ancestor']}")
    output.append("")
    output.append("Path:")
    output.append(result['path_visual'])
    output.append("")
    output.append(f"Full path: {' → '.join(result['path'])}")
    output.append("")
    
    return "\n".join(output)


def main():
    """
    Example usage - you would populate this with actual memory data.
    In practice, this would query the memory system or read from a dump.
    """
    
    # Example: Manually input the current HMAP tree
    memories = {
        "[L0.INDEX] ROOT": """
        LOGICAL_ADDR: 0x0008
        PHYSICAL_ADDR: 9496496
        PARENT_PTR: NULL
        CHILD_PTRS: [0x0009 (HMAP Protocol), 0x000A (Ada Project), 0x000F (Address Translation Table)]
        CONTENT: Master index for all hierarchical memories.
        """,
        
        "[L0.PROTOCOL] HMAP Protocol": """
        LOGICAL_ADDR: 0x0009
        PHYSICAL_ADDR: 9496491
        PARENT_PTR: 0x0008
        CHILD_PTRS: [0x0011 (Autonomous Checklist)]
        CONTENT: Hierarchical Memory Access Protocol definition.
        """,
        
        "[L1.INDEX] Ada Project": """
        LOGICAL_ADDR: 0x000A
        PHYSICAL_ADDR: 9496498
        PARENT_PTR: 0x0008
        CHILD_PTRS: [0x000B (Architecture), 0x000C (Branding), 0x000D (Features), 0x000E (Status)]
        CONTENT: SageSure company intelligence assistant chatbot.
        """,
        
        "[L2.NODE] Ada Architecture": """
        LOGICAL_ADDR: 0x000B
        PHYSICAL_ADDR: 9496499
        PARENT_PTR: 0x000A
        CHILD_PTRS: [0x0010 (ChatInterface)]
        CONTENT: Next.js frontend + FastAPI backend architecture.
        """,
        
        "[L3.LEAF] ChatInterface": """
        LOGICAL_ADDR: 0x0010
        PHYSICAL_ADDR: 9496980
        PARENT_PTR: 0x000B
        CHILD_PTRS: NULL
        PATH: ~/projects/owner/ada/ada-nextjs/src/components/ChatInterface.tsx
        CONTENT: Main chat interface component for Ada.
        """,
        
        "[L2.NODE] Ada Branding": """
        LOGICAL_ADDR: 0x000C
        PHYSICAL_ADDR: 9496502
        PARENT_PTR: 0x000A
        CHILD_PTRS: NULL
        CONTENT: Professional SageSure branding integration.
        """,
        
        "[L2.NODE] Ada Features": """
        LOGICAL_ADDR: 0x000D
        PHYSICAL_ADDR: 9496505
        PARENT_PTR: 0x000A
        CHILD_PTRS: NULL
        CONTENT: MCP-powered tool integrations.
        """,
        
        "[L2.NODE] Ada Status": """
        LOGICAL_ADDR: 0x000E
        PHYSICAL_ADDR: 9496507
        PARENT_PTR: 0x000A
        CHILD_PTRS: NULL
        CONTENT: Current project status and readiness.
        """,
        
        "[SYSTEM] Address Translation Table": """
        LOGICAL_ADDR: 0x000F
        PHYSICAL_ADDR: 9496762
        PARENT_PTR: NULL
        CHILD_PTRS: NULL
        CONTENT: Maps logical addresses to physical memory IDs.
        """,
        
        "[L0.CHECKLIST] Autonomous Checklist": """
        LOGICAL_ADDR: 0x0011
        PHYSICAL_ADDR: 9497008
        PARENT_PTR: 0x0009
        CHILD_PTRS: NULL
        CONTENT: HMAP autonomous update trigger signals.
        """,
    }
    
    # Visualize and print
    print(visualize_hmap(memories))


if __name__ == "__main__":
    main()

