import math

GRAVITY = 1150.0
VX_RUN = 280.0
V_JUMP = -500.0

def test_jump(x1_right, y1_top, x2_left, y2_top, name=""):
    gap = x2_left - x1_right
    dy = y1_top - y2_top # positive = upward
    h_max = (V_JUMP**2) / (2 * GRAVITY)
    if dy > h_max:
        return False, f"FAIL {name}: dy={dy:.1f} > h_max={h_max:.1f}"
    disc = V_JUMP**2 - 2 * GRAVITY * dy
    if disc < 0:
        return False, f"FAIL {name}: disc < 0"
    t_land = (-V_JUMP + math.sqrt(disc)) / GRAVITY
    max_reach = VX_RUN * t_land
    margin = max_reach - gap
    if margin < 15.0:
        return False, f"FAIL {name}: gap={gap:.1f} > safe reach ({max_reach:.1f}, margin={margin:.1f})"
    return True, f"OK {name}: gap={gap:.1f}, dy={dy:.1f}, reach={max_reach:.1f}, margin={margin:.1f}"

def test_launch(x_launch, y_launch, vx, vy, y_target_top, x_target_left, x_target_right, name=""):
    dy = y_launch - y_target_top
    h_max = (vy**2) / (2 * GRAVITY)
    if dy > h_max:
        return False, f"FAIL {name}: launch rise dy={dy:.1f} > max peak {h_max:.1f}"
    disc = vy**2 - 2 * GRAVITY * dy
    if disc < 0:
        return False, f"FAIL {name}: launch disc < 0"
    t = (-vy + math.sqrt(disc)) / GRAVITY
    x_land = x_launch + vx * t
    if x_land < x_target_left + 15 or x_land > x_target_right - 15:
        return False, f"FAIL {name}: lands at {x_land:.1f}, outside [{x_target_left:.1f}, {x_target_right:.1f}]"
    return True, f"OK {name}: lands at {x_land:.1f} inside [{x_target_left:.1f}, {x_target_right:.1f}]"

print("Validator loaded.")
