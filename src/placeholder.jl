struct PlaceHolder end

import Base

□ = PlaceHolder()

Base.show(io::IO, ::PlaceHolder) = print(io, "□")
