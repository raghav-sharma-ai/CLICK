import re, glob, math

# Physics constants from player.gd and project settings
GRAVITY = 1150.0
VX_RUN = 280.0
V_JUMP = -500.0

# Max jump height: v0^2 / (2 * g) = 500^2 / (2 * 1150) = 108.7 px
H_MAX_JUMP = (V_JUMP**2) / (2.0 * GRAVITY)

def parse_tscn(path):
    with open(path, "r") as f:
        content = f.read()
    
    # Extract nodes
    # node format: [node name="..." type="..." (or parent="...") ...]
    # followed by properties
    nodes = {}
    current_node = None
    
    for line in content.split("\n"):
        line = line.strip()
        if line.startswith("[node "):
            m_name = re.search(r'name="([^"]+)"', line)
            m_parent = re.search(r'parent="([^"]+)"', line)
            m_inst = re.search(r'instance=ExtResource\("([^"]+)"\)', line)
            if m_name:
                name = m_name.group(1)
                parent = m_parent.group(1) if m_parent else "."
                nodes[name] = {
                    "name": name,
                    "parent": parent,
                    "props": {}
                }
                current_node = nodes[name]
        elif current_node and "=" in line and not line.startswith("["):
            k, v = line.split("=", 1)
            current_node["props"][k.strip()] = v.strip()
            
    return nodes

def parse_vector2(val_str):
    m = re.search(r'Vector2\(([^)]+)\)', val_str)
    if m:
        parts = [float(p.strip()) for p in m.group(1).split(",")]
        return parts[0], parts[1]
    return 0.0, 0.0

def analyze_level(lvl_num):
    path = f"scenes/levels/level_{lvl_num}.tscn"
    nodes = parse_tscn(path)
    print(f"\n==================== LEVEL {lvl_num} ====================")
    
    # Group platforms, moving platforms, launch pads, hazards, goal, player
    platforms = []
    moving_platforms = []
    launch_pads = []
    hazards = []
    goal = None
    player = None
    
    for name, n in nodes.items():
        parent = n["parent"]
        props = n["props"]
        pos_str = props.get("position", "Vector2(0, 0)")
        px, py = parse_vector2(pos_str)
        size_str = props.get("size", "Vector2(100, 20)")
        sx, sy = parse_vector2(size_str)
        
        if parent == "Platforms" or (parent == "." and "Platform" in name):
            platforms.append({"name": name, "x": px, "y": py, "w": sx, "h": sy, "top": py - sy/2.0})
        elif parent == "MovingPlatforms":
            move_offset = parse_vector2(props.get("move_offset", "Vector2(0, 0)"))
            moving_platforms.append({
                "name": name, "x": px, "y": py, "w": sx, "h": sy, "top": py - sy/2.0,
                "dx": move_offset[0], "dy": move_offset[1]
            })
        elif parent == "LaunchPads":
            imp_str = props.get("launch_impulse", "Vector2(0, -650)")
            ix, iy = parse_vector2(imp_str)
            launch_pads.append({"name": name, "x": px, "y": py, "vx": ix, "vy": iy})
        elif parent == "Hazards":
            w = float(props.get("width", "30.0"))
            h = float(props.get("height", "20.0"))
            hazards.append({"name": name, "x": px, "y": py, "w": w, "h": h})
        elif name == "Goal":
            goal = {"name": name, "x": px, "y": py}
        elif name == "Player":
            player = {"name": name, "x": px, "y": py}
            
    print(f"Player start: ({player['x']}, {player['y']})")
    print(f"Goal: ({goal['x']}, {goal['y']})")
    print(f"Platforms ({len(platforms)}):")
    for p in sorted(platforms, key=lambda p: p['x']):
        print(f"  {p['name']:20s} x={p['x']:6.1f} y={p['y']:6.1f} (top={p['top']:6.1f}, w={p['w']:5.1f}, x_range=[{p['x']-p['w']/2:.1f}, {p['x']+p['w']/2:.1f}])")
    
    if moving_platforms:
        print(f"Moving Platforms ({len(moving_platforms)}):")
        for m in moving_platforms:
            print(f"  {m['name']:20s} x={m['x']:6.1f} y={m['y']:6.1f} top={m['top']:6.1f} w={m['w']:5.1f} offset=({m['dx']}, {m['dy']})")
            
    if launch_pads:
        print(f"Launch Pads ({len(launch_pads)}):")
        for l in launch_pads:
            h_max_launch = (l['vy']**2) / (2.0 * GRAVITY)
            print(f"  {l['name']:20s} at ({l['x']}, {l['y']}) impulse=({l['vx']}, {l['vy']}) -> max vertical boost={h_max_launch:.1f}px")

for i in range(4, 16):
    analyze_level(i)
