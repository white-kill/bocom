<template>
  <img class="image" @click="goBack" src="@/assets/image/home/asset-diagnosis.png" alt="" />
</template>

<script>
export default {
  name: "diagnosis",
  methods: {
    goBack() {
      this.$router.back();
    },
  },
};
</script>

<style scoped lang="scss">
.image {
  width: 7.5rem;
  height: 16.5rem;
}
</style>
