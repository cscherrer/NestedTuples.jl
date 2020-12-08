struct PlaceHolder end

import Base

Base.show(io::IO, ::PlaceHolder) = print(io, "□")
