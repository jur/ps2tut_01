#include "regs.h"

.text

.set arch=r5900

.global write_reg64
.global write_reg32
.global read_reg32

.ent write_reg64
#if _MIPS_SIM == _ABIN32
write_reg64:
	sd a1,0(a0)
	jr ra
#else
#if _MIPS_SIM == _ABIO32
write_reg64:
	/* In ABI o32 the 64 bit parameter is stored in registers a2 and a3.
	 * Concat a 64 bit value.
	 */

	/* First cast 32 bit signed to unsigned. Remove sign extension in upper
	 * 32 bits:
	 */
	dsll32  a2,a2,0x0
	dsrl32  a2,a2,0x0

	/* a3 = a3 << 32 */
	dsll32  a3,a3,0x0

	/* a2 = a2 | a3 */
	or      a2,a2,a3

	/* Make 64 bit write to hardware register. */
	sd      a2,0(a0)
	jr      ra
#else
#error "Unsupported ABI."
#endif
#endif
.end write_reg64

.ent write_reg32
write_reg32:
	sw a1,0(a0)
	jr ra
.end write_reg32

.ent read_reg32
read_reg32:
	lw v0,0(a0)
	jr ra
.end read_reg32
