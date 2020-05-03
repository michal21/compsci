#!/usr/bin/julia
# Michał Gancarczyk

module blocksys

import SparseArrays
using  SparseArrays
using  LinearAlgebra

iters = 0
export iters

# Wczytywanie macierzy A z pliku tekstowego
# Dane:
#  fname - ścieżka pliku
# Wynik:
#  A - wczytana macierz
#  n - rozmiar macierzy A
#  l - rozmiar macierzy Ak, Bk, Ck
function loadmatrix(fname::String)
    open(fname) do file
        nl = split(readline(file))
        n = parse(Int64, nl[1])
        l = parse(Int64, nl[2])

        J = Vector{Int64}()
        I = Vector{Int64}()
        V = Vector{Float64}()

        while !eof(file)
            jiv = split(readline(file))
            push!(J, parse(Int64, jiv[1]))
            push!(I, parse(Int64, jiv[2]))
            push!(V, parse(Float64, jiv[3]))
        end

        A = sparse(I, J, V)
        return A, n, l
    end
end
export loadmatrix

# Wczytywanie wektora prawych stron b z pliku tekstowego
# Dane:
#  fname - ścieżka pliku
# Wynik:
#  b - wczytany wektor
#  n - rozmiar wektora b
function loadrvec(fname::String)
    open(fname) do file
        n = parse(Int64, readline(file))
        b = Vector{Float64}()

        while !eof(file)
            push!(b, parse(Float64, readline(file)))
        end

        return b, n
    end
end
export loadrvec

# Obliczanie wektora prawych stron na podstawie macierzy A, oraz wektora x,
# gdzie x = (1, ..., 1)^T
# Dane:
#  A - macierz rzadka A
#  n - rozmiar macierzy A
# Wynik:
#  b - obliczony wektor prawych stron
function calcrvec(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64)
    b = zeros(Float64, n)
    nz = nonzeros(A)
    for i = 1 : n
        for j = nzrange(A, i)
            b[i] += nz[j]
        end
    end
    return b
end
export calcrvec

#println(calcrvec(loadmatrix("Dane16_1_1/A.txt")[1:2]...))

# Rozwiązywanie układu równań liniowych metodą eliminacji Gaussa
# Dane:
#  A - macierz rzadka A
#  n - rozmiar macierzy A
#  l - rozmiar macierzy Ak, Bk, Ck
#  b - wektor prawych stron
# Wynik:
#  r - rozwiązanie układu
# Błędy:
#  zero - napotkano zero na przekątnej macierzy
# Uwaga: Algorytm pracuje na macierzy wejściowej A, oraz wektorze b, modyfikując ich zawartość
function gaussel(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64, b::Vector{Float64})
    global iters = 0

    for y = 1 : n - 1
        if A[y, y] == 0
            error("zero")
        end
        rt::Int64 = min(y + l, n)
        dn::Int64 = min(floor((y + 1) / l + 1) * l, n)
        for yy = y + 1 : dn
            z = A[y, yy] / A[y, y]
            A[y, yy] = 0
            for x = y + 1 : rt
                A[x, yy] -= z * A[x, y]
                iters += 1
            end
            b[yy] -= z * b[y]
        end
    end

    r = Array{Float64}(undef, n)

    for y = n : -1 : 1
        rt::Int64 = min(y + l, n)
        sum = .0
        for x = y + 1 : rt
            sum += A[x, y] * r[x]
            iters += 1
        end
        r[y] = (b[y] - sum) / A[y, y]
    end
    return r
end
export gaussel

# Rozwiązywanie układu równań liniowych metodą eliminacji Gaussa
# z częściowym wyborem elementu głównego
# Dane:
#  A - macierz rzadka A
#  n - rozmiar macierzy A
#  l - rozmiar macierzy Ak, Bk, Ck
#  b - wektor prawych stron
# Wynik:
#  r - rozwiązanie układu
# Błędy:
#  singular - macierz wejściowa jest osobliwa
# Uwaga: Algorytm pracuje na macierzy wejściowej A, oraz wektorze b, modyfikując ich zawartość
function pgaussel(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64, b::Vector{Float64})
    global iters = 0
    ord = collect(1 : n)

    for y = 1 : n - 1
        dn::Int64 = min(floor((y + 1) / l + 1) * l, n)
        rt::Int64 = min(floor((y + 1) / l + 2) * l, n)
        for yy = y + 1 : dn
            max = abs(A[y, ord[y]])
            maxy = y
            for i = yy : dn
                if (abs(A[y, ord[i]]) > max)
                    maxy = i
                    max = abs(A[y, ord[i]])
                end
                iters += 1
            end

            if (abs(max) < eps(Float64))
                error("singular")
            end

            ord[y], ord[maxy] = ord[maxy], ord[y]

            z = A[y, ord[yy]] / A[y, ord[y]]
            A[y, ord[yy]] = 0
            for x = y + 1 : rt
                A[x, ord[yy]] -= z * A[x, ord[y]]
                iters += 1
            end
            b[ord[yy]] -= z * b[ord[y]]
        end
    end

    r = Array{Float64}(undef, n)

    for y = n : -1 : 1
        rt::Int64 = min(floor((ord[y] + 1) / l + 2) * l, n)
        sum = .0
        for x = y + 1 : rt
            sum += A[x, ord[y]] * r[x]
            iters += 1
        end
        r[y] = (b[ord[y]] - sum) / A[y, ord[y]]
    end
    return r
end
export pgaussel

# Obliczanie rozkładu LU macierzy
# Dane:
#  A - macierz rzadka A
#  n - rozmiar macierzy A
#  l - rozmiar macierzy Ak, Bk, Ck
# Wynik:
#  A - rozkład LU
# Błędy:
#  zero - napotkano zero na przekątnej macierzy
# Uwaga: Algorytm pracuje na macierzy wejściowej, modyfikując jej zawartość
function ludecomp(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64)
    global iters = 0

    for y = 1 : n - 1
        if A[y, y] == 0
            error("zero")
        end
        rt::Int64 = min(y + l, n)
        dn::Int64 = min(floor((y + 1) / l + 1) * l, n)
        for yy = y + 1 : dn
            A[y, yy] /= A[y, y]
            for x = y + 1 : rt
                A[x, yy] -= A[y,yy] * A[x, y]
                iters += 1
            end
        end
    end

    return A
end
export ludecomp

# Obliczanie rozkładu LU macierzy z częściowym wyborem elementu głównego
# Dane:
#  A - macierz rzadka A
#  n - rozmiar macierzy A
#  l - rozmiar macierzy Ak, Bk, Ck
# Wynik:
#  A   - rozkład LU
#  ord - wektor permutacji wierszy macierzy
# Błędy:
#  singular - macierz wejściowa jest osobliwa
# Uwaga: Algorytm pracuje na macierzy wejściowej, modyfikując jej zawartość
function pludecomp(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64)
    global iters = 0
    ord = collect(1 : n)

    for y = 1 : n - 1
        dn::Int64 = min(floor((y + 1) / l + 1) * l, n)
        rt::Int64 = min(floor((y + 1) / l + 2) * l, n)
        for yy = y + 1 : dn
            max = abs(A[y, ord[y]])
            maxy = y
            for i = yy : dn
                if (abs(A[y, ord[i]]) > max)
                    maxy = i
                    max = abs(A[y, ord[i]])
                end
                iters += 1
            end

            if (abs(max) < eps(Float64))
                error("singular")
            end

            ord[y], ord[maxy] = ord[maxy], ord[y]

            A[y, ord[yy]] /= A[y, ord[y]]
            for x = y + 1 : rt
                A[x, ord[yy]] -= A[y, ord[yy]] * A[x, ord[y]]
                iters += 1
            end
        end
    end
    return A, ord
end
export pludecomp

# Rozwiązywanie układu równań liniowych z rozkładu LU
# Dane:
#  A - macierz rzadka A w rozkładzie LU
#  n - rozmiar macierzy A
#  l - rozmiar macierzy Ak, Bk, Ck
#  b - wektor prawych stron
# Wynik:
#  r - rozwiązanie układu
function lusolve(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64, b::Vector{Float64})
    global iters = 0
    e = Array{Float64}(undef, n)

    for y = 1 : n
		sum = 0.
		lt::Int64 = max(l * floor((y - 1) / l) - 1, 1)
		for x = lt : y - 1
			sum += A[x, y] * e[x]
            iters += 1
		end
		e[y] = b[y] - sum
	end

    r = Array{Float64}(undef, n)
    for y = n : -1 : 1
        rt::Int64 = min(y + l, n)
        sum = .0
        for x = y + 1 : rt
            sum += A[x, y] * r[x]
            iters += 1
        end
        r[y] = (e[y] - sum) / A[y, y]
    end
    return r
end
export lusolve

# Rozwiązywanie układu równań liniowych z rozkładu LU
#  z częściowym wyborem elementu głównego
# Dane:
#  A - macierz rzadka A w rozkładzie LU
#  n - rozmiar macierzy A
#  l - rozmiar macierzy Ak, Bk, Ck
#  b - wektor prawych stron
# Wynik:
#  r - rozwiązanie układu
function plusolve(A::SparseMatrixCSC{Float64, Int64}, n::Int64, l::Int64, b::Vector{Float64}, ord::Vector{Int64})
    global iters = 0
    e = Array{Float64}(undef, n)

    for y = 1 : n
		sum = 0.
		lt::Int64 = max(l * floor((ord[y] - 1) / l) - 1, 1)
		for x = lt : y - 1
			sum += A[x, ord[y]] * e[x]
            iters += 1
		end
		e[y] = b[ord[y]] - sum
	end

    r = Array{Float64}(undef, n)
    for y = n : -1 : 1
        rt::Int64 = min(l * floor((ord[y] + 1) / l + 2), n)
        sum = .0
        for x = y + 1 : rt
            sum += A[x, ord[y]] * r[x]
            iters += 1
        end
        r[y] = (e[y] - sum) / A[y, ord[y]]
    end
    return r
end
export plusolve

# Rozwiązywanie układu równań liniowych metodą rozkładu LU
# Dane:
#  A - macierz rzadka A
#  n - rozmiar macierzy A
#  l - rozmiar macierzy Ak, Bk, Ck
#  b - wektor prawych stron
# Wynik:
#  r - rozwiązanie układu
# Uwaga: Algorytm pracuje na macierzy wejściowej A, oraz wektorze b, modyfikując ich zawartość
function solvebylu(A, n, l, b)
    global iters = 0

    ludecomp(A, n, l)
    i = iters
    r = lusolve(A, n, l, b)
    iters += i
    return r
end
export solvebylu

# Rozwiązywanie układu równań liniowych metodą rozkładu LU
# z częściowym wyborem elementu głównego
# Dane:
#  A - macierz rzadka A
#  n - rozmiar macierzy A
#  l - rozmiar macierzy Ak, Bk, Ck
#  b - wektor prawych stron
# Wynik:
#  r - rozwiązanie układu
# Uwaga: Algorytm pracuje na macierzy wejściowej A, oraz wektorze b, modyfikując ich zawartość
function psolvebylu(A, n, l, b)
    global iters = 0

    ord = pludecomp(A, n, l)[2]
    i = iters
    r = plusolve(A, n, l, b, ord)
    iters += i
    return r
end
export psolvebylu

# Zapis rozwiązania równania do pliku
# Dane:
#  f - nazwa pliku
#  r - wektor wynikowy
#  n - rozmiar wektora r
function saveresult(fn::String, r::Array{Float64}, n::Int64)
    open(fn, "w") do f
		for i = 1 : n
			println(f, r[i])
		end
	end
end
export saveresult

# Zapis rozwiązania równania, przy obliconym wektorze b, wraz z błędem względnym do pliku
# Dane:
#  f - nazwa pliku
#  r - wektor wynikowy
#  n - rozmiar wektora r
function saveresultcr(fn::String, r::Array{Float64}, n::Int64)
    open(fn, "w") do f
		println(f, norm(ones(n) - r) / norm(r))
		for i = 1 : n
			println(f, r[i])
		end
	end
end
export saveresultcr

function printm(A::SparseMatrixCSC{Float64, Int64}, n::Int64)
    nz = nonzeros(A)
    for i = 1 : n
        for j = nzrange(A, i)
            print("$(nz[j]), ")
        end
        println()
    end
end
end
