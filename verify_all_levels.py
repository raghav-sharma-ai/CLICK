import math

g = 1150.0
vx_run = 280.0
v_jump = -500.0

def check_jump_platforms(x1, w1, y1, x2, w2, y2, name=""):
    edge1 = x1 + w1 / 2.0
    edge2 = x2 - w2 / 2.0
    gap = edge2 - edge1
    dy = y1 - y2 # positive = upward jump
    h_max = (v_jump**2) / (2 * g)
    if dy > h_max:
        return False, f"{name}: FAILED (dy={dy:.0f} > max height {h_max:.0f})"
    disc = v_jump**2 - 2 * g * dy
    if disc < 0:
        return False, f"{name}: FAILED (disc < 0)"
    t_land = (-v_jump + math.sqrt(disc)) / g
    max_reach = vx_run * t_land
    # Player must cover the gap between platforms, plus a safety margin inside the platform
    if gap > max_reach - 20.0:
        return False, f"{name}: FAILED (gap={gap:.0f} > max reach {max_reach:.0f})"
    return True, f"{name}: OK (gap={gap:.0f} <= reach {max_reach:.0f}, dy={dy:.0f})"

def check_launch_platform(x_launch, y_launch, vx, vy, x_target, w_target, y_target, name=""):
    dy = y_launch - y_target
    h_max = (vy**2) / (2 * g)
    if dy > h_max:
        return False, f"{name}: LAUNCH FAILED (dy={dy:.0f} > peak {h_max:.0f})"
    disc = vy**2 - 2 * g * dy
    if disc < 0:
        return False, f"{name}: LAUNCH FAILED (disc < 0)"
    t = (-vy + math.sqrt(disc)) / g
    x_land = x_launch + vx * t
    left = x_target - w_target / 2.0
    right = x_target + w_target / 2.0
    if x_land < left + 10 or x_land > right - 10:
        return False, f"{name}: LAUNCH MISS (lands at x={x_land:.0f}, target=[{left:.0f}, {right:.0f}])"
    return True, f"{name}: LAUNCH OK (lands at x={x_land:.0f} in [{left:.0f}, {right:.0f}])"

print("Platform physics solver ready.")
