FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/aidotaosm/nextgen-pokemon-tcg_nextjs_pwa.git && \
    cd nextgen-pokemon-tcg_nextjs_pwa && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG}) && \
    rm -rf .git && \
    sed -i "/export const getAllCardsJSONFromFileBaseIPFS/areturn await Helper.initializePokemonSDK().card.all();" src/utils/networkCalls.tsx

FROM node:alpine

WORKDIR /nextgen-pokemon-tcg_nextjs_pwa
COPY --from=base /git/nextgen-pokemon-tcg_nextjs_pwa .
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production
RUN npm install && \
    for dir in es lib; \
        do sed -i "s/host:/host: process.env.NEXT_PUBLIC_POKEMONTCGAPI_HOST ||/" node_modules/pokemontcgsdk/$dir/configure.js; \
    done

EXPOSE 3001
CMD ([ -f .next/BUILD_ID ] || npm run build) && npm start
