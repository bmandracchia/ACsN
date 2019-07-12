function output = Wrapping_up(input,sigma)

M1 = max(max(input));
M2 = min(min(input));
input = (input - M2)./(M1 -M2);
input = Merge(input,sigma); 
output = (input).*(M1-M2)+ M2;

end