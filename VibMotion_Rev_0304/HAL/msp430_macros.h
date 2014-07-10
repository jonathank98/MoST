/** 
 *	\page doc_page MSP430 Port Pin and Register Bit macros for C
 *
 *  \section desc_sec Description
 *	C language macros providing easy to read and understand pin and bit manipulation
 *  for ports and registers in the MSP430.  These are wrappers for the fundamental
 *  C statements used to "set", "clear" or "toggle" one or more port pins and
 *  register bits.  Port configuration macros are provided as well.
 *
 * \section ex_sec Examples:
 * 
 *  TO MANIPULATE I/O PINS:\n
 *  SET_PINS(P2OUT, BIT6+BIT7)\n
 *  CLR_PINS(P1OUT, BIT0)\n
 *  TOGGLE_PINS(P3OUT,BIT4)\n
 *  PORT5_CLR_PINS(BIT2+BIT7)\n
 * 
 *  TO MANIPULATE REGISTER BITS:\n
 *  SET_BITS(UCB0CTL1,UCSWRST)\n
 *  CLR_BITS(UCB0IE, UCTXIE)\n
 *  TOGGLE_BITS(UCB0IE, UCRXIE)\n
 *
 *  TO CONFIGURE PORTS:\n
 *	PORT_PINS_DIGITAL_OUT(P3OUT,BIT5+BIT6+BIT7)\n
 *  PORT2_PINS_DIGITAL_IN(BIT3)\n
 *
 *	TO CONFIGURE SECONDARY FUNCTIONS:\n
 *	PORT_PINS_SECONDARY_FUNC(P1OUT,BIT3+BIT6)\n
 *  PORT5_PINS_SECONDARY_FUNC(BIT0+BIT1)\n
 *
 *
 * \section disclaimer_sec Disclaimer
 *
 * THIS PROGRAM IS PROVIDED "AS IS". TI MAKES NO WARRANTIES OR
 * REPRESENTATIONS, EITHER EXPRESS, IMPLIED OR STATUTORY,
 * INCLUDING ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE, LACK OF VIRUSES, ACCURACY OR
 * COMPLETENESS OF RESPONSES, RESULTS AND LACK OF NEGLIGENCE.
 * TI DISCLAIMS ANY WARRANTY OF TITLE, QUIET ENJOYMENT, QUIET
 * POSSESSION, AND NON-INFRINGEMENT OF ANY THIRD PARTY
 * INTELLECTUAL PROPERTY RIGHTS WITH REGARD TO THE PROGRAM OR
 * YOUR USE OF THE PROGRAM.
 *
 * IN NO EVENT SHALL TI BE LIABLE FOR ANY SPECIAL, INCIDENTAL,
 * CONSEQUENTIAL OR INDIRECT DAMAGES, HOWEVER CAUSED, ON ANY
 * THEORY OF LIABILITY AND WHETHER OR NOT TI HAS BEEN ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGES, ARISING IN ANY WAY OUT
 * OF THIS AGREEMENT, THE PROGRAM, OR YOUR USE OF THE PROGRAM.
 * EXCLUDED DAMAGES INCLUDE, BUT ARE NOT LIMITED TO, COST OF
 * REMOVAL OR REINSTALLATION, COMPUTER TIME, LABOR COSTS, LOSS
 * OF GOODWILL, LOSS OF PROFITS, LOSS OF SAVINGS, OR LOSS OF
 * USE OR INTERRUPTION OF BUSINESS. IN NO EVENT WILL TI'S
 * AGGREGATE LIABILITY UNDER THIS AGREEMENT OR ARISING OUT OF
 * YOUR USE OF THE PROGRAM EXCEED FIVE HUNDRED DOLLARS
 * (U.S.$500).
 *
 * Unless otherwise stated, the Program written and copyrighted
 * by Texas Instruments is distributed as "freeware".  You may,
 * only under TI's copyright in the Program, use and modify the
 * Program without any charge or restriction.  You may
 * distribute to third parties, provided that you transfer a
 * copy of this license to the third party and the third party
 * agrees to these terms by its first use of the Program. You
 * must reproduce the copyright notice and any other legend of
 * ownership on each copy or partial copy, of the Program.
 *
 * You acknowlege and agree that the Program contains
 * copyrighted material, trade secrets and other TI proprietary
 * information and is protected by copyright laws,
 * international copyright treaties, and trade secret laws, as
 * well as other intellectual property laws.  To protect TI's
 * rights in the Program, you agree not to decompile, reverse
 * engineer, disassemble or otherwise translate any object code
 * versions of the Program to a human-readable form.  You agree
 * that in no event will you alter, remove or destroy any
 * copyright notice included in the Program.  TI reserves all
 * rights not specifically granted under this license. Except
 * as specifically provided herein, nothing in this agreement
 * shall be construed as conferring by implication, estoppel,
 * or otherwise, upon you, any license or other right under any
 * TI patents, copyrights or trade secrets.
 *
 * You may not use the Program in non-TI devices.
 * 
 * The ECCN is EAR99. 
 * 
 */

/** \file msp430_macros.h
 *
 *	@brief MSP430 Port Pin and Register Bit macros for C
 *  @author Texas Instruments Inc.
 *	@date Aug 2012
 *	@version Version 0.1 - beta release
 *  @note Built with CCS Version 5.2.1.00018
*/

#ifndef _MSP430_MACROS_H_
#define _MSP430_MACROS_H_

#define CRITICAL							_disable_interrupts()
#define SAFE								_enable_interrupts()

#define SET_PINS(port,bits)					(port |= bits)
#define CLR_PINS(port,bits)					(port &= (~(bits)))
#define TOGGLE_PINS(port,bits)				(port ^= bits)

#define SET_BITS(reg,bits)					(reg |= bits)
#define CLR_BITS(reg,bits)					(reg &= (~(bits)))
#define TOGGLE_BITS(reg,bits)				(reg ^= bits)

#define PORT_TOGGLE_PINS(port,bits)			(TOGGLE_PINS(port,bits))
#define PORT1_TOGGLE_PINS(bits)				(TOGGLE_PINS(P1OUT,bits))
#define PORT2_TOGGLE_PINS(bits)				(TOGGLE_PINS(P2OUT,bits))
#define PORT3_TOGGLE_PINS(bits)				(TOGGLE_PINS(P3OUT,bits))
#define PORT4_TOGGLE_PINS(bits)				(TOGGLE_PINS(P4OUT,bits))
#define PORT5_TOGGLE_PINS(bits)				(TOGGLE_PINS(P5OUT,bits))
#define PORT6_TOGGLE_PINS(bits)				(TOGGLE_PINS(P6OUT,bits))
#define PORT7_TOGGLE_PINS(bits)				(TOGGLE_PINS(P7OUT,bits))

#define PORTA_TOGGLE_PINS(bits)				(TOGGLE_PINS(PAOUT,bits))
#define PORTB_TOGGLE_PINS(bits)				(TOGGLE_PINS(PBOUT,bits))
#define PORTC_TOGGLE_PINS(bits)				(TOGGLE_PINS(PCOUT,bits))
#define PORTD_TOGGLE_PINS(bits)				(TOGGLE_PINS(PDOUT,bits))
#define PORTE_TOGGLE_PINS(bits)				(TOGGLE_PINS(PEOUT,bits))
#define PORTF_TOGGLE_PINS(bits)				(TOGGLE_PINS(PFOUT,bits))
#define PORTJ_TOGGLE_PINS(bits)				(TOGGLE_PINS(PJOUT,bits))

#define PORT_PINS_SET(port,bits)			(SET_PINS(port,bits))
#define PORT1_SET_PINS(bits)				(SET_PINS(P1OUT,bits))
#define PORT2_SET_PINS(bits)				(SET_PINS(P2OUT,bits))
#define PORT3_SET_PINS(bits)				(SET_PINS(P3OUT,bits))
#define PORT4_SET_PINS(bits)				(SET_PINS(P4OUT,bits))
#define PORT5_SET_PINS(bits)				(SET_PINS(P5OUT,bits))
#define PORT6_SET_PINS(bits)				(SET_PINS(P6OUT,bits))
#define PORT7_SET_PINS(bits)				(SET_PINS(P7OUT,bits))

#define PORTA_SET_PINS(bits)				(SET_PINS(PAOUT,bits))
#define PORTB_SET_PINS(bits)				(SET_PINS(PBOUT,bits))
#define PORTC_SET_PINS(bits)				(SET_PINS(PCOUT,bits))
#define PORTD_SET_PINS(bits)				(SET_PINS(PDOUT,bits))
#define PORTE_SET_PINS(bits)				(SET_PINS(PEOUT,bits))
#define PORTF_SET_PINS(bits)				(SET_PINS(PFOUT,bits))
#define PORTJ_SET_PINS(bits)				(SET_PINS(PJOUT,bits))

#define PORT_CLR_PINS(port,bits)			(CLR_PINS(port,bits))
#define PORT1_CLR_PINS(bits)				(CLR_PINS(P1OUT,bits))
#define PORT2_CLR_PINS(bits)				(CLR_PINS(P2OUT,bits))
#define PORT3_CLR_PINS(bits)				(CLR_PINS(P3OUT,bits))
#define PORT4_CLR_PINS(bits)				(CLR_PINS(P4OUT,bits))
#define PORT5_CLR_PINS(bits)				(CLR_PINS(P5OUT,bits))
#define PORT6_CLR_PINS(bits)				(CLR_PINS(P6OUT,bits))
#define PORT7_CLR_PINS(bits)				(CLR_PINS(P7OUT,bits))

#define PORTA_CLR_PINS(bits)				(CLR_PINS(PAOUT,bits))
#define PORTB_CLR_PINS(bits)				(CLR_PINS(PBOUT,bits))
#define PORTC_CLR_PINS(bits)				(CLR_PINS(PCOUT,bits))
#define PORTD_CLR_PINS(bits)				(CLR_PINS(PDOUT,bits))
#define PORTE_CLR_PINS(bits)				(CLR_PINS(PEOUT,bits))
#define PORTF_CLR_PINS(bits)				(CLR_PINS(PFOUT,bits))
#define PORTJ_CLR_PINS(bits)				(CLR_PINS(PJOUT,bits))


#define PORT_PINS_DIGITAL_OUT(port,bits)	(SET_PINS(P##port##DIR,bits))
#define PORT1_PINS_DIGITAL_OUT(bits)		(SET_PINS(P1DIR,bits))
#define PORT2_PINS_DIGITAL_OUT(bits)		(SET_PINS(P2DIR,bits))
#define PORT3_PINS_DIGITAL_OUT(bits)		(SET_PINS(P3DIR,bits))
#define PORT4_PINS_DIGITAL_OUT(bits)		(SET_PINS(P4DIR,bits))
#define PORT5_PINS_DIGITAL_OUT(bits)		(SET_PINS(P5DIR,bits))
#define PORT6_PINS_DIGITAL_OUT(bits)		(SET_PINS(P6DIR,bits))
#define PORT7_PINS_DIGITAL_OUT(bits)		(SET_PINS(P7DIR,bits))
#define PORT8_PINS_DIGITAL_OUT(bits)		(SET_PINS(P8DIR,bits))

#define PORTA_PINS_DIGITAL_OUT(bits)		(SET_PINS(PADIR,bits))
#define PORTB_PINS_DIGITAL_OUT(bits)		(SET_PINS(PBDIR,bits))
#define PORTC_PINS_DIGITAL_OUT(bits)		(SET_PINS(PCDIR,bits))
#define PORTD_PINS_DIGITAL_OUT(bits)		(SET_PINS(PDDIR,bits))
#define PORTE_PINS_DIGITAL_OUT(bits)		(SET_PINS(PEDIR,bits))
#define PORTF_PINS_DIGITAL_OUT(bits)		(SET_PINS(PFDIR,bits))
#define PORTJ_PINS_DIGITAL_OUT(bits)		(SET_PINS(PJDIR,bits))

#define PORT_PINS_DIGITAL_IN(port,bits)		(CLR_PINS(P##port##DIR,bits))

#define PORT1_PINS_DIGITAL_IN(bits)			(CLR_PINS(P1DIR,bits))
#define PORT2_PINS_DIGITAL_IN(bits)			(CLR_PINS(P2DIR,bits))
#define PORT3_PINS_DIGITAL_IN(bits)			(CLR_PINS(P3DIR,bits))
#define PORT4_PINS_DIGITAL_IN(bits)			(CLR_PINS(P4DIR,bits))
#define PORT5_PINS_DIGITAL_IN(bits)			(CLR_PINS(P5DIR,bits))
#define PORT6_PINS_DIGITAL_IN(bits)			(CLR_PINS(P6DIR,bits))
#define PORT7_PINS_DIGITAL_IN(bits)			(CLR_PINS(P7DIR,bits))
#define PORT8_PINS_DIGITAL_IN(bits)			(CLR_PINS(P8DIR,bits))

#define PORTA_PINS_DIGITAL_IN(bits)			(CLR_PINS(PADIR,bits))
#define PORTB_PINS_DIGITAL_IN(bits)			(CLR_PINS(PBDIR,bits))
#define PORTC_PINS_DIGITAL_IN(bits)			(CLR_PINS(PCDIR,bits))
#define PORTD_PINS_DIGITAL_IN(bits)			(CLR_PINS(PDDIR,bits))
#define PORTE_PINS_DIGITAL_IN(bits)			(CLR_PINS(PEDIR,bits))
#define PORTF_PINS_DIGITAL_IN(bits)			(CLR_PINS(PFDIR,bits))
#define PORTJ_PINS_DIGITAL_IN(bits)			(CLR_PINS(PJDIR,bits))

#define PORT_SEL_PRIMARY_FUNC(port,bits)	(CLR_BITS(P##port##SEL,bits))
#define PORT1_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(P1SEL,bits))
#define PORT2_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(P2SEL,bits))
#define PORT3_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(P3SEL,bits))
#define PORT4_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(P4SEL,bits))
#define PORT5_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(P5SEL,bits))
#define PORT6_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(P6SEL,bits))
#define PORT7_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(P7SEL,bits))

#define PORTA_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(PASEL,bits))
#define PORTB_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(PBSEL,bits))
#define PORTC_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(PCSEL,bits))
#define PORTD_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(PDSEL,bits))
#define PORTE_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(PESEL,bits))
#define PORTF_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(PFSEL,bits))
#define PORTJ_SEL_PRIMARY_FUNC(bits)		(CLR_BITS(PJSEL,bits))

#define PORT_SEL_SECONDARY_FUNC(port,bits)	(SET_BITS(P##port##SEL,bits))
#define PORT1_SEL_SECONDARY_FUNC(bits)		(SET_BITS(P1SEL,bits))
#define PORT2_SEL_SECONDARY_FUNC(bits)		(SET_BITS(P2SEL,bits))
#define PORT3_SEL_SECONDARY_FUNC(bits)		(SET_BITS(P3SEL,bits))
#define PORT4_SEL_SECONDARY_FUNC(bits)		(SET_BITS(P4SEL,bits))
#define PORT5_SEL_SECONDARY_FUNC(bits)		(SET_BITS(P5SEL,bits))
#define PORT6_SEL_SECONDARY_FUNC(bits)		(SET_BITS(P6SEL,bits))
#define PORT7_SEL_SECONDARY_FUNC(bits)		(SET_BITS(P7SEL,bits))

#define PORTA_SEL_SECONDARY_FUNC(bits)		(SET_BITS(PASEL,bits))
#define PORTB_SEL_SECONDARY_FUNC(bits)		(SET_BITS(PBSEL,bits))
#define PORTC_SEL_SECONDARY_FUNC(bits)		(SET_BITS(PCSEL,bits))
#define PORTD_SEL_SECONDARY_FUNC(bits)		(SET_BITS(PDSEL,bits))
#define PORTE_SEL_SECONDARY_FUNC(bits)		(SET_BITS(PESEL,bits))
#define PORTF_SEL_SECONDARY_FUNC(bits)		(SET_BITS(PFSEL,bits))
#define PORTJ_SEL_SECONDARY_FUNC(bits)		(SET_BITS(PJSEL,bits))



#endif /*MACROS_H_*/
