import math

# Precompute the arctan table for CORDIC with 50 iterations
MAX_ITERATIONS = 50  
ArcTanTable = [math.atan(2.0**(-i)) for i in range(MAX_ITERATIONS)]  

# Precompute the scaling factor K
K = 1.0
for i in range(MAX_ITERATIONS):
    K *= 1 / math.sqrt(1 + 2.0**(-2 * i))

def CORDIC_function(degrees, iterations=32):
    """
    CORDIC algorithm to calculate sine and cosine.
    :param degrees: Angle in degrees.
    :param iterations: Number of iterations (default 32 for high precision).
    :return: Tuple of (sine, cosine).
    """

    # Convert degrees to radians
    beta = degrees * math.pi / 180.0

    # Ensure iterations do not exceed the table size
    if iterations > MAX_ITERATIONS:
        iterations = MAX_ITERATIONS

    # Initialize vector
    Vx, Vy = 1.0, 0.0

    for i in range(iterations):
        # Determine the rotation direction
        if beta < 0:
            Vx, Vy = Vx + Vy * 2.0**(-i), Vy - Vx * 2.0**(-i)
            beta += ArcTanTable[i]
        else:
            Vx, Vy = Vx - Vy * 2.0**(-i), Vy + Vx * 2.0**(-i)
            beta -= ArcTanTable[i]

    # Apply the final scaling factor
    Vx *= K
    Vy *= K

    # Correct interpretation: Vx = cos(theta), Vy = sin(theta)
    return Vy, Vx

# Taking user input for angle and number of iterations
deg = float(input("Enter the angle in degrees: "))
iter_count = int(input(f"Enter the number of iterations (default 32, max {MAX_ITERATIONS}): ") or 32)

# Call the CORDIC function to calculate sine and cosine
sine, cosine = CORDIC_function(deg, iter_count)

# Output the result
print(f"Sin({deg:.6f}) = {sine:.12f}")
print(f"Cos({deg:.6f}) = {cosine:.12f}")

    