interface ChevronIconProps {
  open: boolean;
}

const ChevronIcon = ({ open }: ChevronIconProps) => (
  <svg
    width="16"
    height="16"
    viewBox="0 0 16 16"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    className={`transform transition-transform ${open ? "rotate-180" : ""}`}
  >
    <path d="M4 6L8 10L12 6" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

export default ChevronIcon;
