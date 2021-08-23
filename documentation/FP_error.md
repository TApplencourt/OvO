# Function to bound

The function we compute for atomic and reduction use case is 

![f(N,M)=\sum^{N \cdot M}\frac{1}{M}](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+f%28N%2CM%29%3D%5Csum%5E%7BN+%5Ccdot+M%7D%5Cfrac%7B1%7D%7BM%7D)

Where `N` is know and `M` in in ![[1,M_{max}]](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5B1%2CM_%7Bmax%7D%5D) and `u` is the machine epsilon

# Relative upper bound error
The upper bound of the Relative error is given in "The Accuracy of Floating Point Summation" (2.6) from Nicholas J. Higham https://doi.org/10.1137/0914050. 
Applied to your function it give:

![\begin{align*}
R_E(N,M) & \le \frac{(N \cdot M-1) \cdot u \cdot f(N,M)}{N} \\
& \le \frac{(N \cdot M-1) \cdot u \cdot N}{N} \\
& \le N \cdot M \cdot u
\end{align*}
](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Balign%2A%7D%0AR_E%28N%2CM%29+%26+%5Cle+%5Cfrac%7B%28N+%5Ccdot+M-1%29+%5Ccdot+u+%5Ccdot+f%28N%2CM%29%7D%7BN%7D+%5C%5C%0A%26+%5Cle+%5Cfrac%7B%28N+%5Ccdot+M-1%29+%5Ccdot+u+%5Ccdot+N%7D%7BN%7D+%5C%5C%0A%26+%5Cle+N+%5Ccdot+M+%5Ccdot+u%0A%5Cend%7Balign%2A%7D%0A)

# Maximun Error

![\max R_E(N,M) = \max N \cdot M \cdot u  =  N \cdot M_{max} \cdot u ](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cmax+R_E%28N%2CM%29+%3D+%5Cmax+N+%5Ccdot+M+%5Ccdot+u++%3D++N+%5Ccdot+M_%7Bmax%7D+%5Ccdot+u+)

### For FP32, maximun problem size to get less than 1%

![\begin{align*}
1\% & \ge NM \cdot 2^{-24} \\
NM & \le \frac{1\%}{2^{-24}} \\
        & \le 167772 \le 55 \cdot 55 \cdot 55
\end{align*}
](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Balign%2A%7D%0A1%5C%25+%26+%5Cge+NM+%5Ccdot+2%5E%7B-24%7D+%5C%5C%0ANM+%26+%5Cle+%5Cfrac%7B1%5C%25%7D%7B2%5E%7B-24%7D%7D+%5C%5C%0A++++++++%26+%5Cle+167772+%5Cle+55+%5Ccdot+55+%5Ccdot+55%0A%5Cend%7Balign%2A%7D%0A)
