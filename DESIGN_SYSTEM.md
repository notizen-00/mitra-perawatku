---
name: Clinical Integrity System
colors:
  surface: "#f8f9ff"
  surface-dim: "#cbdbf5"
  surface-bright: "#f8f9ff"
  surface-container-lowest: "#ffffff"
  surface-container-low: "#eff4ff"
  surface-container: "#e5eeff"
  surface-container-high: "#dce9ff"
  surface-container-highest: "#d3e4fe"
  on-surface: "#0b1c30"
  on-surface-variant: "#3c4a42"
  inverse-surface: "#213145"
  inverse-on-surface: "#eaf1ff"
  outline: "#6c7a71"
  outline-variant: "#bbcabf"
  surface-tint: "#006c49"
  primary: "#006c49"
  on-primary: "#ffffff"
  primary-container: "#10b981"
  on-primary-container: "#00422b"
  inverse-primary: "#4edea3"
  secondary: "#0058be"
  on-secondary: "#ffffff"
  secondary-container: "#2170e4"
  on-secondary-container: "#fefcff"
  tertiary: "#494bd6"
  on-tertiary: "#ffffff"
  tertiary-container: "#9699ff"
  on-tertiary-container: "#1d17b2"
  error: "#ba1a1a"
  on-error: "#ffffff"
  error-container: "#ffdad6"
  on-error-container: "#93000a"
  primary-fixed: "#6ffbbe"
  primary-fixed-dim: "#4edea3"
  on-primary-fixed: "#002113"
  on-primary-fixed-variant: "#005236"
  secondary-fixed: "#d8e2ff"
  secondary-fixed-dim: "#adc6ff"
  on-secondary-fixed: "#001a42"
  on-secondary-fixed-variant: "#004395"
  tertiary-fixed: "#e1e0ff"
  tertiary-fixed-dim: "#c0c1ff"
  on-tertiary-fixed: "#07006c"
  on-tertiary-fixed-variant: "#2f2ebe"
  background: "#f8f9ff"
  on-background: "#0b1c30"
  surface-variant: "#d3e4fe"
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: "700"
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: "700"
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: "600"
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: "400"
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "400"
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: "600"
    lineHeight: 16px
    letterSpacing: 0.05em
  data-mono:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "500"
    lineHeight: 20px
    letterSpacing: -0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-tablet: 32px
---

## Brand & Style

The design system is engineered for a high-stakes healthcare environment, prioritizing clarity, reliability, and calm. The target audience includes medical professionals, administrators, and partners who require rapid data interpretation without cognitive fatigue.

The visual style is **Modern Corporate**, leaning into a clinical yet approachable aesthetic. It utilizes generous whitespace, a systematic grid, and subtle depth to organize complex medical information. The emotional response is one of precision and dependability, ensuring that critical data is always the focal point while the interface remains unobtrusive.

## Colors

The palette is anchored by **Medical Green**, representing health and successful outcomes. **Trust Blue** serves as the primary functional color for actions and links, instilling a sense of institutional stability.

- **Primary (Medical Green):** Used for positive status indicators, health-related success states, and primary CTAs.
- **Secondary (Trust Blue):** Used for navigation elements, information callouts, and secondary actions.
- **Alert (Emergency Red):** Reserved strictly for critical warnings, high-risk patient data, and destructive actions.
- **Neutrals:** A range of cool grays (Slate) provides the structural framework, ensuring that the interface feels "clean" and sanitary.

## Typography

This design system utilizes **Inter** exclusively for its exceptional legibility in data-heavy contexts. The type scale is optimized for rapid scanning.

Numerical data—such as heart rates or lab results—should use the `data-mono` role to ensure alignment in tabular formats. Headlines use a tight letter-spacing to maintain a professional, authoritative tone, while labels are slightly tracked out for immediate identification in small sizes.

## Layout & Spacing

The design system employs an **8px linear scale** for all spatial relationships. On mobile devices, a standard 16px side margin is maintained to prevent content from crowding the screen edges.

Layouts are primarily **fluid**, responding to the device width. For medical data cards, use a single-column layout on mobile, transitioning to a multi-column grid on tablets to maximize information density without sacrificing readability.

## Elevation & Depth

To maintain a "high-trust" feel, this design system avoids heavy, dark shadows. Instead, it uses **Ambient Shadows**—highly diffused, low-opacity (8-12%) shadows with a subtle blue tint (`#3B82F6` at 5% opacity) to ground elements.

- **Level 0 (Surface):** Default background.
- **Level 1 (Cards):** Resting state for patient records and data summaries. Uses a 1px soft border and a minimal shadow.
- **Level 2 (Modals/Pickers):** Higher elevation for temporary interaction layers.

## Shapes

The design system uses a **Rounded** philosophy to soften the clinical nature of the content.

- Standard buttons and input fields utilize a 0.5rem (8px) radius.
- **Medical Data Cards** utilize a larger `rounded-xl` (1.5rem / 24px) corner radius to create distinct, approachable "containers" for information.
- Status indicators (dots) and avatars are fully circular.

## Components

### Buttons & Inputs

- **Primary Action:** Solid Trust Blue background with white text.
- **Medical Action:** Solid Medical Green for "Start Consult" or "Approve."
- **Inputs:** High-contrast borders in Slate-200, moving to Trust Blue on focus.

### Status Indicators

- **Available:** A 10px Medical Green circle with a subtle outer glow.
- **Offline/Busy:** A 10px Slate-400 circle.
- **Emergency:** Pulsing Emergency Red for immediate attention required.

### Medical Data Cards

Cards must feature a consistent header structure: a Label-MD category at the top-left and an icon/status at the top-right. The content area uses Body-LG for primary metrics and Body-MD for secondary descriptions.

### Progress Timelines

Timelines use a vertical orientation on mobile. Completed stages are marked in Medical Green, the active stage in Trust Blue, and upcoming stages in light Slate gray. Lines between nodes are 2px thick.

### Chips

Used for patient tags (e.g., "Critical," "Stable"). Chips have a light tinted background (10% opacity of the status color) and dark text of the same hue to ensure high legibility and soft aesthetics.
