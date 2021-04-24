module PartialPipes

export @pipe

function partial(call::Expr)
    @assert call.head == :call
    body = Expr(:call, call.args..., :x)
    esc(:(x -> $body))
end

function partial(f::Symbol)
    body = Expr(:call, f, :x)
    esc(:(x -> $body))
end

function insert_partials(expr)
    if !(expr isa Expr) || expr.head ≠ :call || expr.args[1] ≠ :|>
        return esc(expr)
    end
    wrap_partial = partial(expr.args[3])
    recursion = insert_partials(expr.args[2])
    Expr(:call, :|>, recursion, wrap_partial)
end

macro pipe(expr)
    insert_partials(expr)
end

end # module
