# What this package was read against

Material Glimmer UI is inspired by Jetpack Compose Glimmer and
Material Design. It contains none of their code, and it is not a port
of either, but the ideas were read from somewhere and this is where.

`tool/fetch_reference.py` mirrors the sources below into `reference/`,
which is not committed and not published: it is Google's code under
Apache 2.0, not ours. This file is the part that is ours to keep, so a
later reader can tell whether the upstream they are looking at is the
one this was compared against.

Gitiles needs a signed-in session for its log endpoint, so what is
pinned here is git tree and blob ids rather than a commit hash. They
identify content exactly, which is the thing worth pinning.

- **Source:** `platform/frameworks/support`, branch `androidx-main`,
  path `xr/glimmer`
- **Read on:** 2026-09-07
- **Refresh with:** `python tool/fetch_reference.py --record`

## Trees

| Path | Tree |
|---|---|
| `glimmer/src/main/java/androidx/xr/glimmer` | `1cb09307fd05782943bb5e968a378bb2f05e5e68` |
| `glimmer/api` | `f7e28eed62e583203fdee98662b25112a05d924c` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples` | `eb2cd13493a639607831797cf439c6f45a49f4ad` |

## Files

| File | Blob |
|---|---|
| `glimmer/api/current.txt` | `44c693a92e363c75d2695dc5dc6521aef447017a` |
| `glimmer/api/res-current.txt` | `e69de29bb2d1d6434b8b29ae775ad8c2e48c5391` |
| `glimmer/api/restricted_current.txt` | `44c693a92e363c75d2695dc5dc6521aef447017a` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/ButtonGroupSamples.kt` | `806c60120aefd739f270538c28e871418306e4f5` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/ButtonSamples.kt` | `77265413422b84c27b39554ddaca0f428be0b47e` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/CardSamples.kt` | `6b68f0a6a3d36152e128dd588f1cde75b6d2eb0b` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/ColorsSamples.kt` | `49aaa33ff229c52ec26de11aa16ff059cb5e70ce` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/DepthEffectLevelsSample.kt` | `3fc2c0f912db5866ead91258bd128ebc8d42c179` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/GlimmerLazyListSamples.kt` | `bed9432ef6df9622fc2d5f37f8c5eb60ca2a8199` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/GlimmerPagerSamples.kt` | `aa292d113dfb43d83a8a56f6b3f4a73e335832e8` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/IconButtonSamples.kt` | `e7237d447d9936834b03e2846c1ad3c8e315581b` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/IconSamples.kt` | `657e6ab3136733c35abd6c568c7e8a0f18e6305f` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/IconToggleButtonSamples.kt` | `ff140e8a2bbd81a51607df59b5d20a4027a63e61` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/IndirectPointerGestureSamples.kt` | `2bc8a192f50786dbfbb03bb2c467e3b2872acaaf` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/ListItemSamples.kt` | `05b112ea890fa7bfcb2a2239445950a56df34b44` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/ShapesSamples.kt` | `628926e4a14ae8212780a6182026049c329b1e8f` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/StackSamples.kt` | `70a5952f432e5535aa8b3ce2bd0a2d1dde6f3a35` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/SurfaceSamples.kt` | `5fd77e70a5629d0ea3e059376877c59cadca93c1` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/TitleChipSamples.kt` | `6f780e6c65c619bf4502206e73ec864ab0273deb` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/ToggleButtonSamples.kt` | `4205c36dcde12174867b49b92757728cd79be298` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/TypographySamples.kt` | `25987692660370262c1958a78ca6494f3e3df5e7` |
| `glimmer/samples/src/main/java/androidx/xr/glimmer/samples/VoiceInputIndicatorSamples.kt` | `6b02a4d2ee51c8984f9ede98d35d5ade060e4671` |
| `glimmer/src/main/java/androidx/xr/glimmer/Border.kt` | `a52fa7bc1345f670f4892cf54271dc3853c0d45f` |
| `glimmer/src/main/java/androidx/xr/glimmer/Button.kt` | `071c3499ce40259a6c211f86cdc8118a29582791` |
| `glimmer/src/main/java/androidx/xr/glimmer/ButtonGroup.kt` | `684c30f4a9265259870049800e173158f9bb42c8` |
| `glimmer/src/main/java/androidx/xr/glimmer/Card.kt` | `70e8b00b46bd8a5e9463441532e6de95d2786f4b` |
| `glimmer/src/main/java/androidx/xr/glimmer/Colors.kt` | `096ab48d2d52928a75b3b92bfe24338bdb544a5c` |
| `glimmer/src/main/java/androidx/xr/glimmer/ComponentSpacingValues.kt` | `54355457a47b56f741c49142a8ba1311291948c2` |
| `glimmer/src/main/java/androidx/xr/glimmer/ContentColor.kt` | `1c2e147b52e56c821e2370e11645cc7e795ce3e3` |
| `glimmer/src/main/java/androidx/xr/glimmer/DepthEffect.kt` | `df12e2f2766e818883d82d752ed93c2c5b44256f` |
| `glimmer/src/main/java/androidx/xr/glimmer/DepthEffectLevels.kt` | `b16f6f0b7b133afc91ea8e60174f9e0039bfaeb6` |
| `glimmer/src/main/java/androidx/xr/glimmer/GlimmerTheme.kt` | `aa02e1bd47ef765b130a769918e337e10a65c4cf` |
| `glimmer/src/main/java/androidx/xr/glimmer/Icon.kt` | `374fdef6fada22172700fbce0df8e0d7f7205115` |
| `glimmer/src/main/java/androidx/xr/glimmer/IconButton.kt` | `ebe4a513e32cdae29e05864da7eccb1fd6404916` |
| `glimmer/src/main/java/androidx/xr/glimmer/IconSizes.kt` | `65dd63a9b251b48f87d5773f6e03341244b4fa39` |
| `glimmer/src/main/java/androidx/xr/glimmer/IconToggleButton.kt` | `3031420217d3d30f32d237e27e67a57f865db614` |
| `glimmer/src/main/java/androidx/xr/glimmer/IndirectPointerGesture.kt` | `17279696f15ce7ce925eb8d77ebaefdcfb75de72` |
| `glimmer/src/main/java/androidx/xr/glimmer/InlineClassHelper.kt` | `81a4198ff07b5e361fa301c02733dbfb2744fc05` |
| `glimmer/src/main/java/androidx/xr/glimmer/ListItem.kt` | `35048cccf6ffdf3ebdfd92e86d6b320bcaa8677f` |
| `glimmer/src/main/java/androidx/xr/glimmer/Scrim.kt` | `3ab85b8d9be8db51669e06373517f911343bd97e` |
| `glimmer/src/main/java/androidx/xr/glimmer/Shapes.kt` | `0131ad67aef21321cebe81c441901b1a02e5ac59` |
| `glimmer/src/main/java/androidx/xr/glimmer/Surface.kt` | `fd621fb22d479b00a398b2026daf35a3e2bcbb0c` |
| `glimmer/src/main/java/androidx/xr/glimmer/Text.kt` | `84850fa0418423cdc7fee60c3238d84f5b851b03` |
| `glimmer/src/main/java/androidx/xr/glimmer/TitleChip.kt` | `86117e029fa4792a9340536db994984857ae0a6c` |
| `glimmer/src/main/java/androidx/xr/glimmer/ToggleButton.kt` | `07a9c9176989b2839ccbb4515194b498c7fba767` |
| `glimmer/src/main/java/androidx/xr/glimmer/Typography.kt` | `2128b7e2e089a4909ea0c8062786a2cc2b63517a` |
| `glimmer/src/main/java/androidx/xr/glimmer/VoiceInputIndicator.kt` | `b442b4af6c24e223d1e5b0633ad93ff6ca75b703` |
| `glimmer/src/main/java/androidx/xr/glimmer/androidx-xr-glimmer-glimmer-documentation.md` | `0d866717ee612db1fa7c2c8c9bbf80cc8588c81e` |
| `glimmer/src/main/java/androidx/xr/glimmer/internal/SingleItemScrollConstraintConnection.kt` | `b91126e6d256c1ee94cd30ae9620efbdf9eefc91` |
| `glimmer/src/main/java/androidx/xr/glimmer/internal/color/HctExtensions.kt` | `4d0e883ce639d8e4458a52ea04f755aa851655be` |
| `glimmer/src/main/java/androidx/xr/glimmer/internal/color/HctSolver.kt` | `9ca39fc986addb848abfdd6d54f5591f5ccec0a7` |
| `glimmer/src/main/java/androidx/xr/glimmer/internal/color/HctUtils.kt` | `c9f30c5bb1fcb38a89129f0232c3b511e3cd04c5` |
| `glimmer/src/main/java/androidx/xr/glimmer/internal/color/ViewingConditions.kt` | `40b983e37d0fa24a7c01ee218a54a292bbdca156` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/AwaitFirstLayoutModifier.kt` | `c4b75ee59154dd995281a4b7e2b7f477fd6af779` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyList.kt` | `9ec16de88042d6f60513f31e46495200ed23be42` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListAutoFocusMeasure.kt` | `00b434494ef27718c0f5746334d3ef107f0da29f` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListAutoFocusNode.kt` | `1e898ebbaf5a386ba208244c410e171107dc85a8` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListAutoFocusProperties.kt` | `e7fbbd158f39dc21a40dc3d828cba4b78e6d4ed7` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListAutoFocusScrollConverter.kt` | `cf4a39bd01e5c7d685e2837c2a1c6a9c2ac429ab` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListAutoFocusState.kt` | `ada37e61ae9c47202f3ea3300b4d9e3c8c5828e2` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListItemProvider.kt` | `29f4c3ee3e9a9d90d982de9c58c9eecd17bd39a3` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListLayoutInfo.kt` | `27b5be6705003a128f940cf7f39da5191e221a42` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListLayoutProperties.kt` | `b34e9b872c27894a75f3a77bb7574dbb59a2a89c` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListMeasure.kt` | `4b34bbd734214e9eb35a24b200780e8ea1612d14` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListMeasurePolicy.kt` | `5884cf0704836acbe3ad1fd9760baa0703b2a34c` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListMeasureResult.kt` | `a0e726a10c77ed495d59aacadbf9e6061b967ada` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListMeasuredItem.kt` | `3da062ee627d71a52d8fe0216ba991c9c034f519` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListMeasuredItemProvider.kt` | `ce715a38f59c6b381e75b15ea1bb157b1cbcb38e` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListScopeMarker.kt` | `bea7f37a0484c3e689cb58d4e14b18eb8d7e2ea6` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListScopes.kt` | `d49bbe2bdeb5d19f65c52bb8dc202be4f6ebccdb` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListScrollPosition.kt` | `77d9cbbe6a8082b0e4bb59bec0d13e704199f823` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListScrollScope.kt` | `d213785bd51176fcc1cf4cf9dce42b94536031dd` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListSemanticState.kt` | `8664f275d63eedde924c3089505acad6312a0337` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListSnapLayoutInfoProvider.kt` | `2cf6e68d95f4bb00e06f84333244f2b69f4447cd` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/GlimmerLazyListState.kt` | `e6ca3a7867261ef6298b768a24810fa9ce460007` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/LazyLayoutBeyondBoundsInfo.kt` | `39d4b7dd0c9603a2543fa6cc200175e6509402a8` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/LazyLayoutBeyondBoundsModifier.kt` | `b1cf313049dd44c98c5b756a0f337e25f4dcd9be` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/LazyLayoutBeyondBoundsState.kt` | `cc31ce5b37eca70ab133970afca4857bdc46a141` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/LazyLayoutNearestRangeState.kt` | `75160c455e188ab39eaa8596947985cdf759c05a` |
| `glimmer/src/main/java/androidx/xr/glimmer/list/LazyLayoutSemantics.kt` | `a7498c800c51a69616feb8b651d59c852ddfd9c9` |
| `glimmer/src/main/java/androidx/xr/glimmer/pager/GlimmerPager.kt` | `69684d6a3d03cb1c6fdbd74df78915cd75609f77` |
| `glimmer/src/main/java/androidx/xr/glimmer/pager/GlimmerPagerAutoFocus.kt` | `95f9df9407bf93f8e773582f9bf60a3ed558c3f3` |
| `glimmer/src/main/java/androidx/xr/glimmer/pager/GlimmerPagerLayoutInfo.kt` | `37a3765dbd46472528c18ca7255d96b57cfa9672` |
| `glimmer/src/main/java/androidx/xr/glimmer/pager/GlimmerPagerPageIndicator.kt` | `92bcec3fc69b9006b92c88270b788441402518b3` |
| `glimmer/src/main/java/androidx/xr/glimmer/pager/GlimmerPagerScope.kt` | `2d5f0d0be060c00309967ef3c0cbe704aac7878e` |
| `glimmer/src/main/java/androidx/xr/glimmer/pager/GlimmerPagerScrimModifier.kt` | `8849c8ec3ff276bf79b989e03f10f74fa7a11358` |
| `glimmer/src/main/java/androidx/xr/glimmer/pager/GlimmerPagerState.kt` | `c43ad79e4bf72baff7e30dfd41b7a3dea1b9aee6` |
| `glimmer/src/main/java/androidx/xr/glimmer/stack/DefaultStackItemKey.kt` | `87c52a25312785202b9d464c041f883eb4150173` |
| `glimmer/src/main/java/androidx/xr/glimmer/stack/Stack.kt` | `26826a25e98aaa3313c8ee83a653ff42a91f7417` |
| `glimmer/src/main/java/androidx/xr/glimmer/stack/StackInitialFocusModifier.kt` | `272cac3b78efaa6579248bc5113c8dc20a28a0bc` |
| `glimmer/src/main/java/androidx/xr/glimmer/stack/StackItemScope.kt` | `d53508c516401b10e317be3bb21eaaacd2076a5d` |
| `glimmer/src/main/java/androidx/xr/glimmer/stack/StackScope.kt` | `7dc114956c64a1ac4c0b33a1f2f089dbe13ca177` |
| `glimmer/src/main/java/androidx/xr/glimmer/stack/StackScrimModifier.kt` | `ee199b3e4dcfce7585fd4267b2e989a07a6bb705` |
| `glimmer/src/main/java/androidx/xr/glimmer/stack/StackState.kt` | `c7b4f2eeb105577f0c7e158aac6e9f6e5b9e7580` |
